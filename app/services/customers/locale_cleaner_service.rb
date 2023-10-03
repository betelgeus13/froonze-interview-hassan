# frozen_string_literal: true

# Shopify customer.locale value is a bit weird. It consists of 2 parts. First is language, second - country where the user is located
# This produces weird locales, like en-VN. We could take just the first part, but some locales do need 2 parts, like pt-BR and pt-PT
module Customers
  class LocaleCleanerService

    LOCALES_WITH_TWO_PARTS = Set[
      'pt-BR',
      'pt-PT',
      'zh-CN',
      'zh-TW',
      'zh-HK',
    ].freeze

    def self.call(locale)
      return locale if locale.in?(LOCALES_WITH_TWO_PARTS)
      locale.split('-').first
    end

  end
end
