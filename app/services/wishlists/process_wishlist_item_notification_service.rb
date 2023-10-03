# frozen_string_literal: true

module Wishlists
  class ProcessWishlistItemNotificationService
    LIMIT_SETTINGS = %i[
      wishlist_notifications_daily_limit
      wishlist_notifications_weekly_limit
      wishlist_notifications_monthly_limit
      wishlist_reminder_notification_products_count
    ]

    def call(wishlist_item:, notification_type:)
      return { error: 'Item has already been notified' } if wishlist_item.notified_at?

      @customer = wishlist_item.customer

      return { error: 'Cannot notify items without a customer' } if @customer.blank?
      return { error: 'Customer unsubscribed or bounced or spammed' } if @customer.skip_notification?

      @shop = wishlist_item.shop

      return { error: 'Product not in stock or in store' } unless product_in_store(wishlist_item:)

      ret = limit_reached?
      return { error: ret[:error] } if ret[:error]

      wishlist_item_ids = [wishlist_item.id] + other_wishlist_item_ids(wishlist_item:, notification_type:)

      ::Wishlists::NotificationJob.perform_async(wishlist_item_ids:, notification_type:)
      {}
    end

    private

    def other_wishlist_item_ids(wishlist_item:, notification_type:)
      return [] if notification_type != WishlistEmailTemplate::REMINDER
      return [] if settings.wishlist_reminder_notification_products_count.to_i <= 1

      ids = []
      added_product_ids = Set.new([wishlist_item.product_id])
      @customer.wishlist_items
               .notifiable.where.not(id: wishlist_item.id).preload(:product)
               .find_each(batch_size: settings.wishlist_reminder_notification_products_count - 1) do |wishlist_item|
        if product_in_store(wishlist_item:) && !added_product_ids.include?(wishlist_item.product_id)
          ids << wishlist_item.id
          added_product_ids << wishlist_item.product_id
        end

        break if ids.size >= (settings.wishlist_reminder_notification_products_count.to_i - 1)
      end
      ids
    end

    def settings
      settings = Setting.select(LIMIT_SETTINGS).find_by(shop_id: @shop.id)
    end

    def product_in_store(wishlist_item:)
      wishlist_item.product.in_store? && wishlist_item.product.variants.dig(wishlist_item.variant_external_id.to_s, 'in_stock')
    end

    def limit_reached?
      return { error: 'Daily limit reached' } if @customer.sent_emails.last_day.count >= settings.wishlist_notifications_daily_limit
      return { error: 'Weekly limit reached' } if @customer.sent_emails.last_week.count >= settings.wishlist_notifications_weekly_limit
      return { error: 'Monthly limit reached' } if @customer.sent_emails.last_month.count >= settings.wishlist_notifications_monthly_limit

      {}
    end
  end
end
