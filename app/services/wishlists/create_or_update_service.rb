module Wishlists
  class CreateOrUpdateService
    ACCEPTED_ACTIONS = [
      ADD = 'add',
      REMOVE = 'remove'
    ]

    def initialize(shop:, customer:, product:, variant_external_id:, action:, guest_id:, list:)
      @shop = shop
      @customer = customer
      @product = product
      @deactivate_all_items = variant_external_id.blank? && action == REMOVE
      @variant_external_id = variant_external_id || product.variants.keys.first
      @action = action
      @guest_id = guest_id || SecureRandom.urlsafe_base64(12)
      @list = list
      @query = @customer ? @customer.wishlist_items : @shop.wishlist_items.where(guest_id: @guest_id)
    end

    def call
      # remove all active wishlist items if the request comes from a collection and customeris present
      return deactivate_all_items if @deactivate_all_items

      @customer ? process_customer_request : process_guest_request
    rescue StandardError => e
      Utils::RollbarService.error(e, shop_id: @shop.id, customer_id: @customer&.id, product_id: @product.id, action: @action, guest_id: @guest_id,
                                     list: @list)
      { error: 'Something went wrong. Please reload the page and try again' }
    end

    private

    def process_customer_request
      wishlist_item = get_item
      wishlist_item.shop = @shop
      wishlist_item.product = @product

      case @action
      when ADD
        active = true
        counter = :add_counter
        broadcast_method = :on_wishlist_add
      when REMOVE
        active = false
        counter = :remove_counter
        broadcast_method = :on_wishlist_remove
      else
        return handle_action_not_supported
      end

      wishlist_item = update_item_and_broadcast(wishlist_item:, active:, counter:, broadcast_method:)
      Wishlists::CustomerCacheJob.perform_async(customer_id: @customer.id)

      { wishlist_items: [wishlist_item] }
    end

    def process_guest_request
      wishlist_item = get_item
      wishlist_item.shop = @shop
      wishlist_item.product = @product

      case @action
      when ADD
        wishlist_item = update_item_and_broadcast(wishlist_item:, active: true, counter: :add_counter, broadcast_method: nil)
      when REMOVE
        ActiveRecord::Base.transaction do
          # save if it exists already
          wishlist_item.update!(active: false) if wishlist_item.persisted?
          update_daily_activity(counter: :remove_counter)
        end
      else
        return handle_action_not_supported
      end

      { wishlist_items: [wishlist_item] }
    end

    def deactivate_all_items
      active_wishlist_items_ids = @query.where(
        product_id: @product.id,
        shop_id: @shop.id,
        added_to_cart_at: nil,
        list: @list,
        order_completed_at: nil,
        active: true
      ).pluck(:id)

      wishlist_items = WishlistItem.where(id: active_wishlist_items_ids)

      ActiveRecord::Base.transaction do
        wishlist_items.update_all(active: false, updated_at: Time.current)
        update_daily_activity(counter: :remove_counter)
      end

      if @customer
        Wishlists::CustomerCacheJob.perform_async(customer_id: @customer.id)

        broadcast_service = Integrations::BroadcastService.new(shop: @shop)
        wishlist_items.each do |wishlist_item|
          broadcast_service.on_wishlist_remove(wishlist_item:)
        end
      end

      { wishlist_items: }
    end

    def get_item(active_item: false)
      params = {
        variant_external_id: @variant_external_id,
        product_id: @product.id,
        shop_id: @shop.id,
        added_to_cart_at: nil,
        list: @list,
        order_completed_at: nil
      }
      params[:active] = true if active_item
      @query.where(params).first_or_initialize
    end

    def update_daily_activity(counter:)
      wishlist_daily_activity = @shop.wishlist_daily_activity_for_today

      WishlistDailyActivity.increment_counter(counter, wishlist_daily_activity.id)
    end

    def handle_action_not_supported
      error = 'Wishlist action not supported'
      Utils::RollbarService.error(
        error,
        shop_id: @shop.id,
        customer_id: @customer&.id,
        product_id: @product.id,
        action: @action,
        guest_id: @guest_id,
        list: @list
      )
      { error: }
    end

    def update_item_and_broadcast(wishlist_item:, active:, counter:, broadcast_method:)
      ActiveRecord::Base.transaction do
        wishlist_item.update!(active:)
        update_daily_activity(counter:)
      end

      Integrations::BroadcastService.new(shop: @shop).send(broadcast_method, wishlist_item:) if broadcast_method
      wishlist_item
    rescue ActiveRecord::RecordNotUnique => e
      Utils::RollbarService.warning(
        e,
        shop_id: @shop.id,
        customer_id: @customer&.id,
        product_id: @product.id,
        action: @action,
        guest_id: @guest_id,
        list: @list
      )
      get_item(active_item: true)
    end
  end
end
