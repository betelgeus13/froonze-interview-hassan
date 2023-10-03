module Loyalty
  class EarningRuleFetcherService

    ORDER_EARNING_TYPE_DEFAULT_SETTINGS = {
      order_earning_type: LoyaltyEarningRule::ORDER_INCREMENT_EARNING_TYPE,
      order_increment_spending_unit: 1,
      order_period_limit_enabled: false,
      order_period_limit_value: 1,
      order_period_limit_unit: 'year',
    }.freeze

    def initialize(shop, earning_type)
      @shop = shop
      @earning_type = earning_type
    end

    def call
      # it does not matter if the rule is not active
      rule = @shop.loyalty_earning_rules.where(earning_type: @earning_type).last
      return rule if rule.present?

      create_params = {
        earning_type: @earning_type,
        value: 100,
        deactivated_at: Time.current
      }
      if @earning_type == LoyaltyEarningRule::ORDER_TYPE
        create_params = create_params.merge(ORDER_EARNING_TYPE_DEFAULT_SETTINGS.deep_dup)
      end
      @shop.loyalty_earning_rules.create!(create_params)
    end

  end
end
