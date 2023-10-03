# frozen_string_literal: true
module Shopify
  module Loyalty
    class CustomerMetafieldDefinitionCreatorService

      class CreateError < StandardError; end

      CREATE_MUTATION = ShopifyAPI::GraphQL.client.parse <<-'GRAPHQL'
        mutation ($definition: MetafieldDefinitionInput!) {
          metafieldDefinitionCreate(definition: $definition) {
            createdDefinition {
              id
            }
            userErrors {
              code
            }
          }
        }
      GRAPHQL

      METAFIELD_DEFINITION = {
        namespace: '$app:froonze_cp',
        name: 'Loyalty data',
        key: 'loyalty_data',
        type: 'json',
        ownerType: 'CUSTOMER',
        access: {
          admin: 'MERCHANT_READ'
        },
        visibleToStorefrontApi: true, # this flag allows rendering metafields in liquid
      }.freeze

      def initialize(shop)
        @shop = shop
      end

      def call
        variables = { definition: METAFIELD_DEFINITION }
        @shop.with_shopify_session do
          result = ShopifyAPI::GraphQL.client.query(CREATE_MUTATION, variables:)
          report_and_raise_error(result.errors.messages) if result.errors.present?

          user_errors = result.data.metafield_definition_create.user_errors
          if user_errors.present? && user_errors.first.code != 'TAKEN' # TAKEN means this metafield definition already exists
            report_and_raise_error(user_errors.first.code)
          end
          result
        end
      end

      private

      def report_and_raise_error(error)
        error = CreateError.new(error)
        Utils::RollbarService.error(error)
        raise error
      end

    end
  end
end
