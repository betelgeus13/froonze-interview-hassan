# frozen_string_literal: true
module Shopify
  module Subscriptions
    class FetcherService

      class FetchingError < StandardError; end

      QUERY = ShopifyAPI::GraphQL.client.parse <<-'GRAPHQL'
        query ($id: ID!) {
          node(id: $id) {
            ... on AppSubscription {
              id
              status
            }
          }
        }
      GRAPHQL

      def initialize(shop, subscription_id)
        @shop = shop
        @subscription_id = subscription_id
      end

      def call
        @shop.with_shopify_session do
          variables = { id: "gid://shopify/AppSubscription/#{@subscription_id}" }
          result = ShopifyAPI::GraphQL.client.query(QUERY, variables: variables)
          if result.errors.present?
            Utils::RollbarService.error(FetchingError.new, errors: result.errors)
            return { error: 'Could not find subscription' }
          end
          { remote_subscription: result.data.node }
        end
      end

    end
  end
end
