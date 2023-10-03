# frozen_string_literal: true
module WidgetTranslations
  class FetcherService

    LOYALTY_SPENDING_RULE_KEY_PREFIX = 'spending_rule_title_'

    def initialize(shop, widget_type, locale)
      @shop = shop
      @widget_type = widget_type
      @locale = locale
      @forms_fetcher = WidgetTranslations::FormTextsFetcherService.new(@shop) if custom_forms?
    end

    def call
      if !WidgetTranslation::WIDGET_TYPES.include?(@widget_type)
        return { error: 'Invalid widget type provided' }
      elsif !WidgetTranslation::LOCALES.keys.include?(@locale)
        return { error: 'Invalid locale provided' }
      end

      widget_translation = @shop.widget_translations.find_by(widget_type: @widget_type, locale: @locale)

      default_english = WidgetTranslations::DefaultsFetcherService.call(@widget_type, 'en')
      default_locale = WidgetTranslations::DefaultsFetcherService.call(@widget_type, @locale)
      default_translation = default_english.deep_merge(default_locale)

      current_translation = if widget_translation
        default_translation.deep_merge(widget_translation.value.deep_symbolize_keys)
      else
        default_translation
      end

      if custom_forms?
        custom_fields_texts = @forms_fetcher.fetch_forms
        default_english = default_english.deep_merge(custom_fields_texts)
        current_translation = custom_fields_texts.deep_merge(current_translation)
        # leave only translations for existing forms and fields:
        form_slugs = custom_fields_texts.keys
        keys_to_leave = form_slugs + %i[shared errors]
        current_translation = current_translation.slice(*keys_to_leave)
        form_slugs.each do |form_slug|
          form_texts = current_translation[form_slug]
          current_translation[form_slug] = form_texts.slice(*custom_fields_texts[form_slug].keys)
        end
      end

      if customer_page? && @shop.plugins['custom_pages'] && custom_pages_titles_mapping.present?
        default_english[:custom_pages] = custom_pages_titles_mapping
        current_translation = { custom_pages: custom_pages_titles_mapping }.deep_merge(current_translation)
        current_translation[:custom_pages] = current_translation[:custom_pages].slice(*custom_pages_titles_mapping.keys) # leave only translations for existing CustomPages
      end

      if loyalty? && @shop.loyalty_active?
        add_loyalty_spending_rules_titles(default_english, current_translation)
      end

      response = {
        current: current_translation,
        original: default_english,
      }
      response[:form_names_mapping] = @forms_fetcher.fetch_form_names_mapping if custom_forms?
      response
    end

    private

    def customer_page?
      @widget_type == WidgetTranslation::CUSTOMER_PAGE_TYPE
    end

    def custom_forms?
      @widget_type == WidgetTranslation::CUSTOM_FORMS
    end

    def loyalty?
      @widget_type == WidgetTranslation::LOYALTY
    end

    def custom_pages_titles_mapping
      return @custom_pages_titles_mapping unless @custom_pages_titles_mapping.blank?
      custom_pages = @shop.setting.customer_page_navigation.select do |nav_item|
        nav_item['type'] == CustomerPageConstants::CUSTOM_PAGE_NAV
      end
      @custom_pages_titles_mapping = custom_pages.each_with_object({}) do |page, mapping|
        mapping[page['page_id'].to_s.to_sym] = page['page_title']
      end
    end

    def add_loyalty_spending_rules_titles(default_english, current_translation)
      spending_rules = @shop.loyalty_spending_rules.active
      existing_spending_rule_ids = spending_rules.map(&:id).to_set
      spending_rule_titles_mapping = spending_rules.each_with_object({}) do |spending_rule, mapping|
        translation_key = "#{LOYALTY_SPENDING_RULE_KEY_PREFIX}#{spending_rule.id}".to_sym
        mapping[translation_key] = spending_rule.title
      end
      default_english[:customer_page] = default_english[:customer_page].deep_merge(spending_rule_titles_mapping)
      current_translation[:customer_page] = spending_rule_titles_mapping.deep_merge(current_translation[:customer_page])
      # leave only translations for existing spending rules:
      current_translation[:customer_page].delete_if do |key, _|
        next false unless key.starts_with?(LOYALTY_SPENDING_RULE_KEY_PREFIX)
        spending_rule_id = key.to_s.split(LOYALTY_SPENDING_RULE_KEY_PREFIX).second.to_i
        !spending_rule_id.in?(existing_spending_rule_ids)
      end
    end

  end
end
