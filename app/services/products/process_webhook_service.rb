# frozen_string_literal: true

module Products
  class ProcessWebhookService
    WISHLIST_SETTINGS = %i[
      wishlist_back_in_stock_notification_enabled
      wishlist_low_on_stock_notification_enabled
      wishlist_low_on_stock_notification_low_stock_threshold
      wishlist_price_drop_notification_enabled
    ]

    def initialize(shop:)
      @shop = shop
    end

    def call(webhook:)
      shopify_product = Utils::DeepStruct.new.call(object: webhook)[:result]

      product = @shop.products.find_by(external_id: shopify_product.id)
      product ||= @shop.products.find_by(handle: shopify_product.handle)

      old_product = product.dup

      ret = Products::FactoryService.new(shop: @shop).call(shopify_product:, product:)
      return ret if ret[:error]

      product = ret[:product]

      # There cannot be any existing wishlist items without a product
      return {} if old_product.nil?

      # no need to send emails if product is not in store
      return {} unless product.in_store?

      schedule_notifications(old_product:, product:)

      {}
    end

    private

    def schedule_notifications(old_product:, product:)
      back_in_stock_ids = low_on_stock_ids = price_drop_ids = []

      back_in_stock_ids = back_in_stock_ids(old_product:, product:) if settings.wishlist_back_in_stock_notification_enabled
      low_on_stock_ids = low_on_stock_ids(old_product:, product:) if settings.wishlist_low_on_stock_notification_enabled
      price_drop_ids = price_drop_ids(old_product:, product:) if settings.wishlist_price_drop_notification_enabled

      low_on_stock_ids -= back_in_stock_ids
      price_drop_ids = price_drop_ids - low_on_stock_ids - back_in_stock_ids
      return if back_in_stock_ids.blank? && low_on_stock_ids.blank? && price_drop_ids.blank?

      ::Wishlists::ProcessProductNotificationsJob.perform_async(
        shop_id: @shop.id,
        product_id: product.id,
        back_in_stock_ids:,
        low_on_stock_ids:,
        price_drop_ids:
      )
    end

    def price_drop_ids(old_product:, product:)
      product.variants.each_with_object([]) do |(variant_external_id, data), ids|
        next unless old_product.variants[variant_external_id]

        old_price = old_product.variants.dig(variant_external_id, 'price').to_i

        ids << variant_external_id if old_price > data['price'].to_i
      end
    end

    def back_in_stock_ids(old_product:, product:)
      product.variants.each_with_object([]) do |(variant_external_id, data), ids|
        next unless old_product.variants[variant_external_id]

        old_in_stock = old_product.variants.dig(variant_external_id, 'in_stock')

        ids << variant_external_id if !old_in_stock && data['in_stock']
      end
    end

    def low_on_stock_ids(old_product:, product:)
      product.variants.each_with_object([]) do |(variant_external_id, data), ids|
        if data['quantity'] && data['quantity'] <= settings.wishlist_low_on_stock_notification_low_stock_threshold
          ids << variant_external_id
        end
      end
    end

    def settings
      @settings ||= Setting.select(WISHLIST_SETTINGS).find_by(shop_id: @shop.id)
    end
  end
end
