# frozen_string_literal

module Shopify
  module Metafields
    class GqlPublisherService

      MUTATION = ShopifyAPI::GraphQL.client.parse <<-"GRAPHQL"
        mutation($input: [MetafieldsSetInput!]!) {
          metafieldsSet(metafields: $input) {
            metafields {
              id
              namespace
              key
            }
            userErrors {
              field
              message
            }
          }
        }
      GRAPHQL

      def self.publish(metafields:)
        response = ShopifyAPI::GraphQL.client.query(MUTATION, variables: { input: metafields })
        errors = response.original_hash.dig('data', 'metafieldsSet', 'userErrors').presence || response.original_hash.dig('errors').presence
        return { error: errors.first['message'] } if errors.present?

        { metafield: response.original_hash.dig('data', 'metafieldsSet', 'metafields') }
      end
    end
  end
end
