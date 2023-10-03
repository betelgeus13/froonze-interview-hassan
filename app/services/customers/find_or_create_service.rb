# frozen_string_literal: true

module Customers
  class FindOrCreateService
    def initialize(shop:)
      @shop = shop
    end

    def call(external_id:)
      customer = @shop.customers.find_by(external_id: external_id)

      return { customer: customer } if customer.present?

      @shop.with_shopify_session do
        shopify_customer = ShopifyAPI::Customer.find(external_id)
        customer_params = Customers::CustomerParamsService.new.call(shopify_customer: shopify_customer)[:customer_params]
        ret = Customers::FactoryService.new(shop: @shop).create_or_update(params: customer_params)
        return { error: ret[:error] } if ret[:error]

        { customer: ret[:customer] }
      rescue ActiveResource::ResourceNotFound => e
        { error: 'Account was not found on Shopify' }
      rescue ActiveResource::TimeoutError => e
        { error: 'Please try again later' }
      end
    end
  end
end
