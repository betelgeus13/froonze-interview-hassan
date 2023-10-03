module Shopify
  module Metafields
    class FormsUpdaterService

      METAFIELD_NAMESPACE = 'custom_forms'
      METAFIELD_KEY = 'settings'
      METAFIELD_TYPE = 'json'

      def self.call(shop:, forms_settings:)
        metafield = {
          namespace: METAFIELD_NAMESPACE,
          key: METAFIELD_KEY,
          type: METAFIELD_TYPE,
          value: forms_settings.to_json,
          ownerId: shop.app_installation_id
        }
        ret = shop.with_shopify_session do
          Shopify::Metafields::GqlPublisherService.publish(metafields: [metafield])
        end
        raise ret[:error] if ret[:error]
      end

    end
  end
end
