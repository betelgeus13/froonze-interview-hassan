module MerchantDashboard
  class TextsLoaderService

    CACHED_TEXTS = {}
    DEFAULT_LOCALE = 'en'

    def self.call(locale)
      cached_texts = CACHED_TEXTS[locale]
      return cached_texts.deep_dup if cached_texts.present?
      texts = load_texts(locale)
      texts = if locale == DEFAULT_LOCALE
        texts
      else
        default_texts = load_texts(DEFAULT_LOCALE)
        default_texts.deep_merge(texts)
      end
      CACHED_TEXTS[locale] = texts
      texts.deep_dup
    end

    def self.load_texts(locale)
      all_texts = {}
      Dir["#{Rails.root}/lib/translations/merchant_dashboard/**/#{locale}.yml"].each do |file_path|
        new_texts = YAML.load_file(file_path)
        all_texts = all_texts.deep_merge(new_texts)
      end
      all_texts
    end

  end
end
