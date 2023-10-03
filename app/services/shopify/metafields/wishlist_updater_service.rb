module Shopify
  module Metafields
    class WishlistUpdaterService
      METAFIELD_TYPE = 'json'
      METAFIELD_KEY = 'wishlist'

      def call(shop:, lists:, customer_external_id:, active_wishlist_list:, list_names:, shared_wishlist_slugs: {})
        shop.with_shopify_session do
          Shopify::MetafieldService.publish_for_resource(
            key: METAFIELD_KEY,
            value: {
              lists:,
              updatedAt: Time.current,
              customerId: customer_external_id,
              activeList: active_wishlist_list,
              listNames: list_names,
              sharedWishlistSlugs: shared_wishlist_slugs
            }.to_json,
            external_id: customer_external_id,
            resource: 'customer',
            type: METAFIELD_TYPE
          )
        end
      end
    end
  end
end
