# frozen_string_literal

module Shopify
  class MetafieldService
    NAMESPACE = 'froonze_cp'

    def self.publish(key:, value:, type: 'json')
      metafield = ShopifyAPI::Metafield.new(namespace: NAMESPACE, key: key, value: value, type: type)
      metafield.save!
      metafield
    end

    def self.unpublish(key:)
      ShopifyAPI::Metafield.where(namespace: NAMESPACE, key: key).first&.destroy
    end

    def self.publish_for_resource(key:, value:, external_id:, resource: 'customer', type: 'json')
      metafield = ShopifyAPI::Metafield.new(
        namespace: NAMESPACE,
        key: key,
        value: value,
        owner_id: external_id,
        type: type,
        owner_resource: resource
      )
      metafield.save!
      metafield
    end

    def self.find(key:)
      ShopifyAPI::Metafield.where(namespace: NAMESPACE, key: key).first
    end
  end
end
