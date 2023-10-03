module Shopify
  class TranslationService

    PUSH_QUERY = ShopifyAPI::GraphQL.client.parse <<-"GRAPHQL"
      mutation($resourceId: ID!, $translations: [TranslationInput!]!) {
        translationsRegister(resourceId: $resourceId, translations: $translations) {
          translations {
            key
            locale
            outdated
            value
          }
          userErrors {
            code
            field
            message
          }
        }
      }
    GRAPHQL

    def self.push_translation(resource_id, translations)
      response = ShopifyAPI::GraphQL.client.query(PUSH_QUERY, variables: { resourceId: resource_id, translations: translations })
      { result: response&.to_h }
    end

  end
end
