# frozen_string_literal: true

# not used anymore as preparation for built for shopify badge and 04/2023 api
module ShopifyThemes
  class AddCollectionWishlistSnippetService
    COLLECTION_WISHLIST_CONTENT = File.read('lib/liquid_templates/snippets/collection_wishlist.liquid')
    SNIPPET_KEY = 'snippets/frcp-collection-wishlist.liquid'

    def initialize(shop:)
      @shop = shop
    end

    def call(theme_external_id:)
      @shop.with_shopify_session do
        ShopifyAPI::Asset.new(key: SNIPPET_KEY, value: COLLECTION_WISHLIST_CONTENT, theme_id: theme_external_id).save!
      end
    end
  end
end
