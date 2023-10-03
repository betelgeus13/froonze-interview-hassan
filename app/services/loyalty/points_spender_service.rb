# frozen_string_literal: true
module Loyalty
  class PointsSpenderService

    class SpendPointsError < StandardError; end

    def initialize(customer:, spending_rule:, increment_points_to_spend: nil, increment_discount_value: nil)
      @customer = customer
      @shop = customer.shop
      @spending_rule = spending_rule
      @points_to_spend = spending_rule.increment_points_discount? ? increment_points_to_spend : spending_rule.points_cost
      @increment_discount_value = increment_discount_value
    end

    def call
      return { error: 'Customer is not a loyalty program member' } if @customer.excluded_from_loyalty?
      return { error: 'Spending rule is discarded' } if @spending_rule.discarded?
      return { error: 'Spending rule is not active' } unless @spending_rule.active?
      return { error: 'Customer does not have enough points' } if @customer.loyalty_points.to_i < @points_to_spend.to_i

      process_discount if @spending_rule.discount?
    rescue => error
      error = SpendPointsError.new(error)
      Utils::RollbarService.error(error,
        shop_id: @shop.id,
        customer_id: @customer.id,
        spending_rule_id: @spending_rule.id,
        points_to_spend: @points_to_spend
      )
      { error: 'Something went wrong. Please try again' }
    end

    private

    def process_discount
      if @spending_rule.amount_discount?
        process_amount_discount
      elsif @spending_rule.percentage_discount?
        process_percentage_discount
      elsif @spending_rule.free_shipping_discount?
        process_free_shipping_discount
      end
    end

    def process_amount_discount
      if @spending_rule.increment_points_discount?
        return { error: 'points_to_spend cannot be blank' } if @points_to_spend.blank?
        return { error: "points_to_spend should not be lower than #{@spending_rule.points_cost}" } if @points_to_spend < @spending_rule.points_cost
        return { error: "points_to_cost should be divisible by #{@spending_rule.points_cost}" } if @points_to_spend % @spending_rule.points_cost != 0
      end
      variables = generate_shared_discount_variables
      amount = if @spending_rule.increment_points_discount?
        @points_to_spend / @spending_rule.points_cost * @spending_rule.discount_value
      else
        @spending_rule.discount_value
      end
      # Just an extra precaution to check whether the customer was shown the correct amount in FE widget
      if @spending_rule.increment_points_discount? && amount != @increment_discount_value
        return { error: 'increment_discount_value is invalid' }
      end
      variables[:amount] = amount
      create_discount_and_loyalty_event(variables)
    end

    def process_percentage_discount
      variables = generate_shared_discount_variables
      variables[:percentage] = @spending_rule.discount_value.to_f / 100
      create_discount_and_loyalty_event(variables)
    end

    def process_free_shipping_discount
      variables = generate_shared_discount_variables
      if @spending_rule.free_shipping_max_price_enabled
        variables[:maximum_shipping_price] = @spending_rule.free_shipping_max_price
      end
      variables[:combines_with_product_and_order_discounts] = @spending_rule.free_shipping_combines_with_product_and_order_discounts
      create_discount_and_loyalty_event(variables)
    end

    def generate_shared_discount_variables
      variables = {
        code: SecureRandom.hex(6).upcase,
        customer_ids: ["gid://shopify/Customer/#{@customer.external_id}"]
      }
      if @spending_rule.off_discount?
        if @spending_rule.discount_min_order_requirement_enabled
          variables[:min_order_subtotal] = @spending_rule.discount_min_order_subtotal
        end
        if @spending_rule.discount_applied_to_collections?
          variables[:collection_ids] = @spending_rule.discount_collection_ids.map do |collection_id|
            "gid://shopify/Collection/#{collection_id}"
          end
        end
        variables[:combines_with_free_shipping] = @spending_rule.discount_combines_with_free_shipping
      end
      if @spending_rule.discount_expiration_enabled?
        variables[:ends_at] = @spending_rule.discount_expires_after_days.days.from_now.iso8601
      end
      variables
    end

    def create_discount_and_loyalty_event(variables)
      local_discount = nil
      discount_external_id = nil
      Loyalty::EventCreatorHelperService.call(@customer) do
        loyalty_event = @customer.loyalty_events.spend_points.create!(
          loyalty_spending_rule: @spending_rule,
          points: -@points_to_spend
        )
        local_discount = create_local_discount(loyalty_event, variables)
        discount_external_id = create_remote_discount(variables)
        loyalty_event
      end
      local_discount.update(external_id: discount_external_id)
      {
        discount: local_discount,
        customer_points: @customer.loyalty_points
      }
    end

    def create_local_discount(loyalty_event, variables)
      value = if @spending_rule.amount_discount?
        variables[:amount]
      elsif @spending_rule.percentage_discount?
        variables[:percentage] * 100
      end
      loyalty_event.create_loyalty_discount!(
        value:,
        code: variables[:code],
        ends_at: variables[:ends_at],
        min_order_subtotal: variables[:min_order_subtotal],
        collection_ids: variables[:collection_ids],
        free_shipping_max_price: variables[:maximum_shipping_price],
        discount_combines_with_free_shipping: variables[:combines_with_free_shipping],
        free_shipping_combines_with_product_and_order_discounts: variables[:combines_with_product_and_order_discounts],
      )
    end

    def create_remote_discount(variables)
      result = if @spending_rule.amount_discount?
        Shopify::Loyalty::OffDiscountCreatorService.new(@shop).create_amount_discount(variables)
      elsif @spending_rule.percentage_discount?
        Shopify::Loyalty::OffDiscountCreatorService.new(@shop).create_percentage_discount(variables)
      elsif @spending_rule.free_shipping_discount?
        Shopify::Loyalty::FreeShippingDiscountCreatorService.new(@shop).call(variables)
      end
      raise result[:error] if result[:error]
      result[:discount_id]
    end

  end
end
