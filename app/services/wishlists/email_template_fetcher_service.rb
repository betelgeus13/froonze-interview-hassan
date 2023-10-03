# frozen_string_literal: true

module Wishlists
  class EmailTemplateFetcherService
    def initialize(shop:)
      @shop = shop
    end

    def get_all(email_type:)
      templates = @shop.wishlist_email_templates.where(email_type:).to_a
      default_template = @shop.wishlist_email_templates.new(**WishlistEmailTemplate::DEFAULTS[email_type])

      templates << default_template unless templates.find { |et| et.default? }

      { templates: }
    end

    def get_with_locale(email_type:, locale:)
      return { error: 'Please make sure email type is present' } if email_type.blank?

      templates = @shop.wishlist_email_templates.where(email_type:, locale: [locale, WishlistEmailTemplate::DEFAULT_LOCALE])
      exact_locale = templates.find { |et| et.locale == locale }

      return { result: exact_locale } if exact_locale

      return { result: templates.first } if templates.present?

      { result: @shop.wishlist_email_templates.new(**WishlistEmailTemplate::DEFAULTS[email_type]) }
    end
  end
end
