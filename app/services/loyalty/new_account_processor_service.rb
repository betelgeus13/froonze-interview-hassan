module Loyalty
  class NewAccountProcessorService

    def initialize(customer)
      @customer = customer
    end

    def call
      return unless @customer.state_enabled?
      return if @customer.excluded_from_loyalty?
      return if @customer.loyalty_events.create_account.exists?
      shop = @customer.shop
      return unless shop.loyalty_active?
      loyalty_earning_rule = shop.loyalty_earning_rules.active.create_account_type.take
      return if loyalty_earning_rule.blank?

      points_to_add = loyalty_earning_rule.value
      Loyalty::EventCreatorHelperService.call(@customer) do
        @customer.loyalty_events.create_account.create!(loyalty_earning_rule:, points: points_to_add)
      end
    end

  end
end
