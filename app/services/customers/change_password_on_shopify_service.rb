# frozen_string_literal: true

module Customers
  class ChangePasswordOnShopifyService
    def initialize(shop:)
      @shop = shop
    end

    def update(params)
      return { error: "Password don't match." } if params[:password] != params[:password_confirmation]

      @shop.with_shopify_session do
        ret = find_remote_customer(params[:external_id])
        return ret if ret[:error]

        remote_customer = ret[:result]

        remote_customer.password = params[:password]
        remote_customer.password_confirmation = params[:password_confirmation]

        Customers::EnsureRemoteCustomerEmailMarketingStateService.call(remote_customer:)
        remote_customer.save!
      end
      {}
    end

    private

    def find_remote_customer(shopify_id)
      { result: ShopifyAPI::Customer.find(shopify_id) }
    rescue ActiveResource::ResourceNotFound => e
      { error: 'Account was not found on Shopify' }
    rescue ActiveResource::TimeoutError => e
      { error: 'Please try again later' }
    end
  end
end
