# frozen_string_literal: true

module ThemeCustomizations
  class PublisherService
    METAFIELD_TYPE = 'json'

    def initialize(shop, customization_type)
      @shop = shop
      @customization_type = customization_type
    end

    def call
      current_type_customizations = @shop.shopify_theme_customizations.where(customization_type: @customization_type)
      current_type_customizations_json = current_type_customizations.inject({}) do |hash, theme_customization|
        external_theme_id = theme_customization.shopify_theme.external_id
        hash[external_theme_id] = theme_customization.slice(:html, :css, :js).compact.stringify_keys
        hash
      end.to_json

      @shop.with_shopify_session do
        metafield_key = "#{@customization_type}_customization"
        Shopify::MetafieldService.publish(key: metafield_key, value: current_type_customizations_json, type: METAFIELD_TYPE)
      end
    end

  end
end
