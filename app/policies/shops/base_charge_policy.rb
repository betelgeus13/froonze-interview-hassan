# Scenarios:
# Shop just installed
#     -> customers_count is lower than MIN threshold
#         -> use for free
#     -> customers_count is higher than MIN threshold
#         -> block using MD unless they subscribe
# Shop installed some time ago. That time MIN threshold was not reached, but now it is
#     -> shop does not have an active subscription
#         -> block MD
#     -> shop has an active subscription
#         -> shop did not exceed customers_count MAX limit
#             -> do not block MD, just apply new base charge for new subscriptions
#         -> shop exceeded customers_count MAX limit
#             -> shop.custom_base_charge_in_cents is not set
#                 -> block MD and show "contact support" message
#             -> shop.custom_base_charge_in_cents is set
#                 -> do not block MD, just apply new base charge for new subscriptions

module Shops
  class BaseChargePolicy

    def initialize(shop)
      @shop = shop
      @subscriptions_manager = Shopify::Subscriptions::ManagerService.new(shop)
    end

    def pending?
      return false if @subscriptions_manager.base_charge&.zero?
      return true if @subscriptions_manager.custom_base_charge? && @shop.custom_base_charge_in_cents.blank?
      @shop.active_shopify_subscription.blank?
    end

  end
end
