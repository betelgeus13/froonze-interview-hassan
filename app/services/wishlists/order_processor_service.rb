module Wishlists
  class OrderProcessorService

    def initialize(order)
      @order = order
      @shop = order.shop
      @customer = order.customer
    end

    def call
      return if @order.cart_token.blank?

      order_data = @order.data['line_items'].each_with_object({}) do |line_item, hash|
        hash[line_item['variant_id'] ] = {
          price: line_item['price'],
          quantity: line_item['fulfillable_quantity']
        }
      end

      wishlist_items = @customer.wishlist_items.where(
        cart_token: @order.cart_token,
        variant_external_id: order_data.keys,
        order_completed_at: nil
      )

      value = {}
      total_price = wishlist_items.map(&:variant_external_id).uniq.inject(0) do |total_price, variant_external_id|
        data = order_data[variant_external_id]
        value[variant_external_id] = data[:price].to_f * data[:quantity].to_i * 100
        total_price += value[variant_external_id]

        total_price
      end

      wishlist_daily_activity = @shop.wishlist_daily_activity_for_today

      broadcast_service = Integrations::BroadcastService.new(shop: @shop)
      ActiveRecord::Base.transaction do
        wishlist_items.each do |wishlist_item|
          wishlist_item.shop = @shop
          wishlist_item.update!(order_completed_at: @order.placed_at)
          broadcast_service.on_wishlist_bought(wishlist_item: wishlist_item, value: value[wishlist_item.variant_external_id])
        end
        WishlistDailyActivity.update_counters(wishlist_daily_activity.id, ordered_value: total_price)
      end
    end

  end
end
