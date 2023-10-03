# frozen_string_literal: true

module Shopify
  class SetShopAppInstallationIdService
    class FetchingError < StandardError; end

    QUERY = ShopifyAPI::GraphQL.client.parse <<-'GRAPHQL'
      query {
        appInstallation {
          id
        }
      }
    GRAPHQL

    def call(shop:)
      shop.with_shopify_session do
        result = ShopifyAPI::GraphQL.client.query(QUERY)
        if result.errors.present?
          Utils::RollbarService.error(FetchingError.new, errors: result.errors)
          return { error: 'Error something went bad' }
        end

        shop.update(app_installation_id: result.data.app_installation.id)
      end
      {}
    end
  end
end
