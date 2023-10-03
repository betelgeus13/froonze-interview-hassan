# frozen_string_literal: true

module Customers
  class FindOrCreateByEmailService
    def initialize(shop:)
      @shop = shop
    end

    def call(email:)
      customer = @shop.customers.find_by(email:)

      return { customer: } if customer.present?

      @shop.with_shopify_session do
        shopify_customer = ShopifyAPI::Customer.find(:first, from: :search, params: { query: email })
        customer_params = Customers::CustomerParamsService.new.call(shopify_customer:)[:customer_params]
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
