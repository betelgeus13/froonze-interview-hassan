module Wishlists
  class SyncGuestWishlistService
    def initialize(shop:, customer:, guest_id:, add:, remove:, list:)
      @shop = shop
      @customer = customer
      @guest_id = guest_id
      @add = add
      @remove = remove
      @customer_lists = customer.wihslist_lists.to_a.to_set
      @list = ensure_customer_list(list:)
      @broadcast_service = Integrations::BroadcastService.new(shop:)
    end

    def call
      process_added_items
      process_removed_items
      Wishlists::CustomerCacheJob.perform_async(customer_id: @customer.id)
      {}
    end

    def process_added_items
      @shop.wishlist_items.where(
        guest_id: @guest_id,
        active: true
      ).find_each do |guest_item|
        existing_item = @customer.wishlist_items.find_by(
          variant_external_id: guest_item.variant_external_id,
          product_id: guest_item.product_id,
          shop_id: @shop.id,
          added_to_cart_at: nil,
          list: ensure_customer_list(list: guest_item.list),
          order_completed_at: nil
        )

        if existing_item
          existing_item.update!(active: true) unless existing_item.active
          guest_item.destroy!
        else
          guest_item.update!(
            customer_id: @customer.id,
            guest_id: nil
          )
          @broadcast_service.on_wishlist_add(wishlist_item: guest_item)
        end
      end
    rescue StandardError => e
      Utils::RollbarService.error(e, shop_id: @shop.id, customer_id: @customer.id, guest_id: @guest_id, add: @add, remove: @remove)
      { error: e.message }
    end

    def process_removed_items
      products = @shop.products.where(handle: @remove.keys).index_by(&:handle)
      @remove.each do |handle, variant_ids|
        variant_ids.each do |variant_id|
          wishlist_item = @customer.wishlist_items.find_by(
            variant_external_id: variant_id,
            product_id: products[handle].id,
            shop_id: @shop.id,
            added_to_cart_at: nil,
            list: @list,
            order_completed_at: nil,
            active: true
          )

          if wishlist_item
            wishlist_item.update(active: false)
            @broadcast_service.on_wishlist_remove(wishlist_item:)
          end
        end
      end
    end

    def ensure_customer_list(list:)
      @customer_lists.include?(list) ? list : @customer.active_wishlist_list_with_default
    end
  end
end
