# frozen_string_literal: true

module Shopify
  module Forms
    class CreateOrUpdateMetafieldDefinitionService
      class CreateError < StandardError; end
      class UpdateError < StandardError; end

      OWNER_TYPE = 'CUSTOMER'

      CREATE_QUERY = ShopifyAPI::GraphQL.client.parse <<-'GRAPHQL'
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

      UPDATE_QUERY = ShopifyAPI::GraphQL.client.parse <<-'GRAPHQL'
        mutation ($definition: MetafieldDefinitionUpdateInput!) {
          metafieldDefinitionUpdate(definition: $definition) {
            updatedDefinition {
              id
            }
            userErrors {
              code
            }
          }
        }
      GRAPHQL

      FIND_BY_KEY_QUERY = ShopifyAPI::GraphQL.client.parse <<-'GRAPHQL'
        query ($namespace: String!, $key: String!) {
          metafieldDefinitions(first: 1, namespace: $namespace, ownerType: CUSTOMER, key: $key) {
            edges {
              node {
                id
                type {
                  name
                }
              }
            }
          }
        }
      GRAPHQL

      ID_STATIC_PART = 'gid://shopify/MetafieldDefinition/'

      def initialize(shop, params)
        @shop = shop
        @params = params
      end

      def call
        @shop.with_shopify_session do
          create_or_update
        end
      end

      private

      def create_or_update
        if remote_metafield_defintion.present?
          if remote_metafield_defintion.dig('type', 'name') != @params[:type]
            return { error: 'metafield_definition_with_another_data_type_exists' }
          end

          update

        else
          create
        end
      end

      def remote_metafield_defintion
        return @remote_metafield_defintion if @remote_metafield_defintion.present?
        return nil if @already_checked_remote_metafield_defintion

        variables = {
          namespace: @params[:namespace],
          key: @params[:key]
        }
        result = ShopifyAPI::GraphQL.client.query(FIND_BY_KEY_QUERY, variables:)
        @remote_metafield_defintion = result.original_hash.dig('data', 'metafieldDefinitions', 'edges', 0, 'node')
        @already_checked_remote_metafield_defintion = true
        @remote_metafield_defintion
      end

      def create
        variables = {
          definition: {
            name: @params[:name],
            namespace: @params[:namespace],
            key: @params[:key],
            type: @params[:type],
            ownerType: OWNER_TYPE
          }
        }
        result = ShopifyAPI::GraphQL.client.query(CREATE_QUERY, variables:)
        if result.errors.present? # most likely error on Shopify's end
          Utils::RollbarService.error(CreateError.new, shop_id: @shop.id, errors: result.errors)
          return {}
        end
        errors = result.data.metafield_definition_create.user_errors
        if errors.present?
          # UNSTRUCTURED_ALREADY_EXISTS - Shopify doesn't allow to create metafield definitions via API if values already exist for given namespace and key
          # It is still possible to create metafield definitions in Shopify admin
          return { notification: 'unstructured_already_exists' } if errors.any? { |e| e.code == 'UNSTRUCTURED_ALREADY_EXISTS' }
          return update if errors.any? { |e| e.code == 'TAKEN' }

          Utils::RollbarService.error(CreateError.new, shop_id: @shop.id, errors:)
          return { error: 'Could not create Shopify metafield definition' }
        end
        {}
      end

      def update
        variables = {
          definition: {
            name: @params[:name],
            namespace: @params[:namespace],
            key: @params[:key],
            ownerType: OWNER_TYPE
          }
        }
        result = ShopifyAPI::GraphQL.client.query(UPDATE_QUERY, variables:)
        errors = result.data.metafield_definition_update.user_errors
        if errors.present?
          Utils::RollbarService.error(UpdateError.new, shop_id: @shop.id, errors:)
          return { error: 'Could not update Shopify metafield definition' }
        end
        {}
      end
    end
  end
end
