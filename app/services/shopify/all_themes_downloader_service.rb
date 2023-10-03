# frozen_string_literal

module Shopify
  class AllThemesDownloaderService

    def initialize(shop:)
      @shop = shop
    end

    def call
      @shop.with_shopify_session do
        ShopifyAPI::Theme.all.each do |theme|
          next unless ShopifyTheme::ROLES.include?(theme.role)
          ShopifyThemes::FactoryService.new(shop: @shop).create_or_update!(params: theme.attributes)
        end
      end
      @shop.shopify_themes.create(ShopifyTheme::GLOBAL_CUSTOMIZATION_PARAMS)
    end
  end
end
