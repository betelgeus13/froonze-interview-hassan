# frozen_string_literal: true
module WidgetTranslations
  class FormTextsFetcherService

    FIELD_ATTRIBUTES = %w(label description default placeholder).freeze
    FIELD_SETTINGS_ATTRIBUTES = %w(content)

    def initialize(shop)
      @shop = shop
    end

    def fetch_forms
      texts = {}
      @shop.forms.preload(form_fields: [:custom_field, :form_field_validations]).each do |form|
        texts[form.slug] = build_form(form)
      end
      texts.deep_symbolize_keys
    end

    def fetch_form_names_mapping
      @shop.forms.each_with_object({}) do |form, mapping|
        mapping[form.slug] = form.name
      end
    end

    private

    def build_form(form)
      texts = {}
      form.form_fields.each do |field|
        next if skip_field?(field)
        build_field(texts, field)
      end
      texts
    end

    def skip_field?(field)
      field.design_divider?
    end

    def build_field(texts, field)
      field.attributes.slice(*FIELD_ATTRIBUTES).each do |key, value|
        next if value.blank?
        next if skip_attribute?(field, key)
        translation_key = "#{field.id}__#{key}"
        texts[translation_key] = value
      end
      if field.has_options?
        field.settings['options'].each do |option|
          key = option.keys.first
          option_key = "#{field.id}__option__#{key}"
          texts[option_key] = key
        end
      end
      field.settings.slice(*FIELD_SETTINGS_ATTRIBUTES).each do |key, value|
        next if value.blank?
        translation_key = "#{field.id}__setting__#{key}"
        texts[translation_key] = value
      end
      field.form_field_validations.each do |validation|
        next if validation.error_message.blank?
        translation_key = "#{field.id}__validation_#{validation.id}__error_message"
        texts[translation_key] = validation.error_message
      end
    end

    def skip_attribute?(field, key)
      field.design? && key == 'label'
    end

  end
end
