module Shopify
  class CollectionsFetcherService

    FIELDS = %w(id title).freeze

    def initialize(shop)
      @shop = shop
    end

    def call
      @shop.with_shopify_session do
        custom_collections = ShopifyAPI::CustomCollection.find(:all, :params => { limit: 250, fields: FIELDS })
        smart_collections = ShopifyAPI::SmartCollection.find(:all, :params => { limit: 250, fields: FIELDS })
        custom_collections.to_a + smart_collections.to_a
      end
    end
  end
end
