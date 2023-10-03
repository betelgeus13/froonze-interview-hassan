module WidgetTranslations
  class DefaultsFetcherService

    DEFAULT_TRANSLATIONS = {}

    def self.call(widget_type, locale)
      return DEFAULT_TRANSLATIONS[widget_type][locale].deep_dup if DEFAULT_TRANSLATIONS.dig(widget_type, locale)

      default_translation_file = "#{Rails.root}/lib/translations/#{widget_type}/#{locale}.yml"
      translations = if File.exist?(default_translation_file)
        YAML.load_file(default_translation_file).deep_symbolize_keys.freeze
      else
        {}
      end
      DEFAULT_TRANSLATIONS[widget_type] ||= {}
      DEFAULT_TRANSLATIONS[widget_type][locale] = translations
      translations.deep_dup
    end

  end
end
