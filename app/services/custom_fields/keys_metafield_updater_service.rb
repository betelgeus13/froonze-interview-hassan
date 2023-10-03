# frozen_string_literal: true

module CustomFields
  class KeysMetafieldUpdaterService
    METAFIELD_NAMESPACE = 'custom_forms'
    METAFIELD_KEY = 'custom_field_namespace_and_keys'
    METAFIELD_TYPE = 'json'
    LEGACY_KEYS = %w[gender date_of_birth].map { |k| [CustomField::SHOPIFY_METAFIELD_NAMESPACE, k] }

    def initialize(shop)
      @shop = shop
    end

    def call
      Shopify::SetShopAppInstallationIdService.new.call(shop: @shop) if @shop.app_installation_id.blank?
      custom_field_data = @shop.custom_fields.map { |cf| [cf.namespace, cf.key] }

      data = (custom_field_data + LEGACY_KEYS).uniq
      metafield = {
        namespace: METAFIELD_NAMESPACE,
        key: METAFIELD_KEY,
        type: METAFIELD_TYPE,
        value: data.to_json,
        ownerId: @shop.app_installation_id
      }
      ret = @shop.with_shopify_session do
        Shopify::Metafields::GqlPublisherService.publish(metafields: [metafield])
      end

      raise ret[:error] if ret[:error]
    end
  end
end
