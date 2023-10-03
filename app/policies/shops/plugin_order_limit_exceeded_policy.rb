module Shops
  class PluginOrderLimitExceededPolicy

    def initialize(shop, plugin)
      @shop = shop
      @plugin = plugin
    end

    def exceeded?
      plugin_info = Shopify::Subscriptions::ManagerService::PLUGIN_INFO[@plugin]
      current_plan = @shop.plugins[@plugin]
      return false if current_plan.blank?
      max_orders_count = plugin_info.dig(:plans, current_plan, :max_orders_count)
      return false if max_orders_count.blank?
      @shop.update_monthly_orders_count if @shop.monthly_orders_count.blank?
      return @shop.monthly_orders_count > max_orders_count
    end

  end
end
