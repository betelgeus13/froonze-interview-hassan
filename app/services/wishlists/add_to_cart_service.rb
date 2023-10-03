module Wishlists
  class AddToCartService
    def call(shop:, customer:, product:, variant_external_id:, selected_variant_external_id:, quantity:, cart_token:, list:)
      list ||= WishlistConstants::DEFAULT_LIST

      wishlist_item = customer.wishlist_items.active.find_by(
        product_id: product.id,
        list:,
        variant_external_id:,
        added_to_cart_at: nil
      )
      return { error: 'Cannot find wishlist item' } if wishlist_item.blank?

      wishlist_item.shop = shop
      wishlist_item.product = product

      wishlist_item.update!(
        added_to_cart_at: Time.current,
        active: false,
        cart_token:,
        variant_external_id: selected_variant_external_id
      )

      wishlist_daily_activity = shop.wishlist_daily_activity_for_today
      price = product.variants.dig(wishlist_item.variant_external_id.to_s, 'price').to_f * 100

      WishlistDailyActivity.update_counters(wishlist_daily_activity.id, added_to_cart_value: price * quantity)

      Wishlists::CustomerCacheJob.perform_async(shop_id: shop.id, customer_id: customer.id)

      Integrations::BroadcastService.new(shop:).on_wishlist_add_to_cart(wishlist_item:, value: price)

      {}
    rescue StandardError => e
      Utils::RollbarService.error(e, shop_id: shop.id, customer_id: customer.id, product_id: product.id, cart_token:,
                                     variant_external_id:, selected_variant_external_id:, list:)
      { error: 'Something went wrong. Please reload the page and try again' }
    end
  end
end
