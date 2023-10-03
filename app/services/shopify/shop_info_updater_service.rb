# frozen_string_literal: true

module Shopify
  class ShopInfoUpdaterService
    class FetchingError < StandardError; end

    QUERY = ShopifyAPI::GraphQL.client.parse <<-'GRAPHQL'
      query {
        shop {
          customerAccounts
        }
      }
    GRAPHQL

    def initialize(shop:)
      @shop = shop
    end

    def call
      @shop.with_shopify_session do
        result = ShopifyAPI::GraphQL.client.query(QUERY)
        if result.errors.present?
          Utils::RollbarService.error(FetchingError.new, errors: result.errors)
          return { error: 'Error something went bad' }
        end
        rest_result = ShopifyAPI::Shop.current
        graphql_results = result.data.shop

        @shop.update(
          name: rest_result.name,
          email: rest_result.email,
          phone: rest_result.phone,
          owner: rest_result.shop_owner,
          custom_domain: rest_result.domain,
          shopify_plan: rest_result.plan_name,
          primary_locale: rest_result.primary_locale,
          password_enabled: rest_result.password_enabled,
          country_code: rest_result.country_code,
          currency: rest_result.currency,
          shopify_customer_account_setting: graphql_results.customer_accounts.downcase
        )
      end
    end
  end
end
