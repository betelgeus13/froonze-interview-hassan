module Settings
  class ValidatorService
    def initialize(shop:)
      @shop = shop
    end

    def call(params:)
      errors = []
      params.each do |field, value|
        ret = validate(field:, value:)
        errors << ret[:error] if ret[:error]
      end

      { error: errors.uniq.join(', ').presence }.compact
    end

    private

    def validate(field:, value:)
      case field.to_s
      when 'wishlist_social_share'
        wishlist_advanced_or_premium = @shop.wishlist_advanced_active? || @shop.wishlist_premium_active?
        return { error: 'Social share requires Advanced or Premium plan' } unless wishlist_advanced_or_premium

        {}
      when 'wishlist_enable_guest'
        wishlist_advanced_or_premium = @shop.wishlist_advanced_active? || @shop.wishlist_premium_active?
        return { error: 'Guest wishlist requires Advanced or Premium plan' } unless wishlist_advanced_or_premium

        {}
      when 'wishlist_enable_multilist'
        wishlist_advanced_or_premium = @shop.wishlist_advanced_active? || @shop.wishlist_premium_active?
        return { error: 'Mulitlist requires Advanced or Premium plan' } unless wishlist_advanced_or_premium

        {}
      when 'wishlist_tag_conditions'
        wishlist_advanced_or_premium = @shop.wishlist_advanced_active? || @shop.wishlist_premium_active?
        return { error: 'Tag conditions requires Advanced or Premium plan' } unless wishlist_advanced_or_premium

        {}

      when 'wishlist_reminder_notification_status'
        wishlist_premium = @shop.wishlist_premium_active?
        if !wishlist_premium && value != SettingConstants::WISHLIST_REMINDER_DISABLED
          return { error: 'Wishlist notifications requires Premium plan' }
        end

        {}
      when 'wishlist_back_in_stock_notification_enabled', 'wishlist_low_on_stock_notification_enabled', 'wishlist_price_drop_notification_enabled'
        wishlist_premium = @shop.wishlist_premium_active?
        return { error: 'Wishlist notifications requires Premium plan' } if !wishlist_premium && value

        {}
      when 'forms_notification_email'
        return { error: 'Invalid email' } if value.present? && !EmailValidator.valid?(value, mode: :strict)

        {}
      else
        {}
      end
    end
  end
end
