module WidgetTranslations
  class TranslatorService

    def initialize(shop, widget_type, locale)
      @widget_type = widget_type
      @locale = locale
      @default_translation = fetch_default_translation
      @translation = shop.widget_translations.where(widget_type:, locale:).take
    end

    def call(section:, key:, variables: {})
      text = @translation&.value&.dig(section, key) || @default_translation.dig(section, key)
      variables.keys.each do |key|
        text = text.gsub("{ #{key} }", variables[key])
      end

      text
    end

    private

    def fetch_default_translation
      default_english = WidgetTranslations::DefaultsFetcherService.call(@widget_type, 'en')
      default_locale = WidgetTranslations::DefaultsFetcherService.call(@widget_type, @locale)
      default_english.deep_merge(default_locale).deep_stringify_keys
    end

  end
end
