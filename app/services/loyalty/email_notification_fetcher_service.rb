module Loyalty
  class EmailNotificationFetcherService

    def initialize(shop, type)
      @shop = shop
      @type = type
    end

    def call
      ActiveRecord::Base.transaction do
        notification = @shop.loyalty_email_notifications.find_or_create_by!(notification_type: @type)
        return notification if notification.loyalty_email_templates.default_locale.exists?
        default_settings = LoyaltyConstants::EMAIL_TEMPLATE_DEFAULTS[@type]
        notification.loyalty_email_templates.default_locale.create!(default_settings)
        notification
      end
    end

  end
end
