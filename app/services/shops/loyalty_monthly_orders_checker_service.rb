module Shops
  class LoyaltyMonthlyOrdersCheckerService

    DAYS_SINCE_DISCOVERY_FOR_EMAIL = Set[0, 7, 30]

    def initialize(shop)
      @shop = shop
    end

    def call
      @shop.update_monthly_orders_count
      discovery_date_meta = @shop.shop_metas.find_or_initialize_by(key: :loyalty_monthly_orders_count_limit_exceeded_discovery_date)
      limit_exceeded = Shops::PluginOrderLimitExceededPolicy.new(@shop, ShopifySubscription::LOYALTY).exceeded?
      if limit_exceeded
        discovery_date_meta.update!(value: Date.current) if discovery_date_meta.value.blank?
        days_since_discovery = Date.current.to_date.mjd - discovery_date_meta.value.mjd
        return unless days_since_discovery.in?(DAYS_SINCE_DISCOVERY_FOR_EMAIL)
        ShopMailer.loyalty_monthly_orders_exceeded_email(@shop).deliver_later
      else
        discovery_date_meta.update(value: nil) if discovery_date_meta.value.present?
      end
    end

  end
end
