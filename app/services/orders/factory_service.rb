# frozen_string_literal: true

module Orders
  class FactoryService
    FIELDS = %w[
      cart_token
      customer_locale
      financial_status
      fulfillment_status
      name
      token
      total_price
      subtotal_price
      currency
      cancelled_at
    ].freeze

    JSON_FIELDS = %w[
      discount_codes
      refunds
      line_items
    ].freeze

    def initialize(shop:, shopify_order:)
      @shop = shop
      @shopify_order = shopify_order
    end

    def create_or_update
      customer_id = @shopify_order.dig('customer', 'id')

      # some orders don't have customers. Like POS orders
      return {} if customer_id.blank?

      ret = Customers::FindOrCreateService.new(shop: @shop).call(external_id: customer_id)
      return {} if ret[:error]

      customer = ret[:customer]

      return {} if customer.blank?

      order = customer.orders.find_or_initialize_by(external_id: @shopify_order['id'])
      params = @shopify_order.slice(*FIELDS)
      params['placed_at'] = @shopify_order['created_at']
      params['data'] = @shopify_order.slice(*JSON_FIELDS)
      begin
        order.update!(params)
        { order: }
      rescue ActiveRecord::RecordNotUnique # this can happen during race condition when create and update webhook jobs run at the same time
        { order: customer.orders.find_by(external_id: @shopify_order['id']) }
      end
    end
  end
end
