# frozen_string_literal: true
module Loyalty
  class OrderProcessorService

    def initialize(order)
      @order = order
      @shop = order.shop
      @customer = order.customer
    end

    def call
      update_customer_locale
      mark_used_discounts
      return if @customer.excluded_from_loyalty?
      @existing_earning_event = find_or_create_earning_event
      return if @existing_earning_event.blank?
      @earning_rule = @existing_earning_event.loyalty_earning_rule
      create_cancel_and_refund_events
    end

    private

    def update_customer_locale
      @customer.update(locale: @order.customer_locale) if @order.customer_locale.present?
    end

    def mark_used_discounts
      codes = @order.data['discount_codes'].map { |discount| discount['code'] }
      @customer.loyalty_discounts.not_used.where(code: codes).each do |discount|
        discount.mark_as_used!(@order)
      end
    end

    def find_or_create_earning_event
      earning_event = @customer.loyalty_events.earning_order.find_by(order_id: @order.id)
      return earning_event if earning_event.present?
      return nil unless @order.paid_or_refunded?
      earning_rule = @shop.loyalty_earning_rules.order_type.active_during(@order.placed_at).take
      return if earning_rule.blank?
      return if period_limit_is_reached?(earning_rule)
      create_earning_event(earning_rule)
    end

    def period_limit_is_reached?(earning_rule)
      return false unless earning_rule.order_period_limit_enabled
      period = earning_rule.order_period_limit_unit
      earning_events = @customer.loyalty_events.earning_order
      if period != LoyaltyEarningRule::LIFETIME_PERIOD_UNIT
        earning_events = earning_events.where('created_at > ?', 1.send(period).ago)
      end
      earning_events.count >= earning_rule.order_period_limit_value
    end

    def create_earning_event(earning_rule)
      new_points = calculate_earning_points(earning_rule)
      earning_event = nil
      Loyalty::EventCreatorHelperService.call(@customer) do
        earning_event = @customer.loyalty_events.earning_order.create!(
          order: @order,
          loyalty_earning_rule: earning_rule,
          points: new_points
        )
      end
      earning_event
    end

    def create_cancel_and_refund_events
      if @earning_rule.order_fixed_type?
        create_cancel_event_if_needed
      elsif @earning_rule.order_increment_type?
        create_refund_events_if_needed
      end
    end

    def create_cancel_event_if_needed
      return unless @order.cancelled?
      return if @customer.loyalty_events.cancel_order.where(order_id: @order.id).exists?
      points_to_deduct = @earning_rule.value
      Loyalty::EventCreatorHelperService.call(@customer) do
        @customer.loyalty_events.cancel_order.create!(
          order: @order,
          points: -points_to_deduct
        )
      end
    end

    def create_refund_events_if_needed
      @order.data['refunds'].each do |refund|
        next if refund_events_mapping[refund['id'].to_s].present?
        refund_points = calculate_refund_points(refund)
        next if refund_points.zero?
        Loyalty::EventCreatorHelperService.call(@customer) do
          @customer.loyalty_events.refund_order.create!(
            order: @order,
            refund_external_id: refund['id'],
            points: -refund_points
          )
        end
      end
    end

    def calculate_refund_points(refund)
      refund_transactions = refund['transactions'].select { |transaction| transaction['kind'] == 'refund' }
      refunded_amount = refund_transactions.sum { |transaction| transaction['amount'].to_f }
      ratio = refunded_amount / subtotal_price
      ratio = [ratio, 1].min
      points_to_deduct = (ratio * @existing_earning_event.points).floor

      already_deducted_points = -(refund_events_query.sum(:points))
      max_points_to_deduct = @existing_earning_event.points - already_deducted_points

      [points_to_deduct, max_points_to_deduct].min
    end

    def refund_events_mapping
      @refund_events_mapping ||= refund_events_query.index_by(&:refund_external_id)
    end

    def refund_events_query
      @customer.loyalty_events
        .refund_order
        .where(order_id: @order.id)
    end

    def calculate_earning_points(rule)
      if rule.order_fixed_type?
        return rule.value
      else
        return (subtotal_price / rule.order_increment_spending_unit * rule.value).floor
      end
    end

    def subtotal_price
      @order.subtotal_price.to_f
    end

  end
end
