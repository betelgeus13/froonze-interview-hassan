# frozen_string_literal: true
module Shopify
  module Metafields
    class DeleterService

      DELETE_MUTATION = ShopifyAPI::GraphQL.client.parse <<-"GRAPHQL"
        mutation($input: MetafieldDeleteInput!) {
          metafieldDelete(input: $input) {
            deletedId
            userErrors {
              field
              message
            }
          }
        }
      GRAPHQL

      DOES_NOT_EXIST_ERROR = 'Metafield does not exist'

      def self.call(id)
        response = ShopifyAPI::GraphQL.client.query(DELETE_MUTATION, variables: { input: { id: id } }).original_hash
        errors = response['errors'] || response.dig('data', 'metafieldDelete', 'userErrors')
        error = errors.first
        if error.present?
          return {} if error['message'] == DOES_NOT_EXIST_ERROR
          { error: error['message'] }
        else
          {}
        end
      end

    end
  end
end
