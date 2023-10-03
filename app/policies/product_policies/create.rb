module ProductPolicies
  class Create
    def initialize(shop:)
      @shop = shop
    end

    def allowed?(new_products_count: 1)
      case @shop.active_shopify_subscription&.wishlist_plan
      when ShopifySubscription::WISHLIST_ADVANCED_PLAN, ShopifySubscription::WISHLIST_PREMIUM_PLAN
        true
      when ShopifySubscription::WISHLIST_BASIC_PLAN
        true
        # TODO: uncommecnt this check after we release unlimitted plan and cache products counts in shop model
        # shop.products_count + new_products_count <= WishlistConstants::BASIC_PLAN_PRODUCT_LIMIT
      else
        false
      end
    end
  end
end
