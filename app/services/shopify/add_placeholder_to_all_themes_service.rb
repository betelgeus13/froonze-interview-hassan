# frozen_string_literal: true

# not used anymore as preparation for built for shopify badge and 04/2023 api
module Shopify
  class AddPlaceholderToAllThemesService
    DELAY = 10.seconds

    def initialize(shop:)
      @shop = shop
    end

    def call
      @shop.with_shopify_session do
        @shop.shopify_themes.each_with_index do |theme, index|
          next unless theme.name.include?('turbo') # do not add placeholder for themes other than turbo.

          if theme.role == 'main'
            ShopifyThemes::AddPlaceholderToAllTemplatesService.new.call(theme:)
          else
            Shopify::AddPlaceholderToThemeJob.perform_in(index * DELAY, shop_id: @shop.id, theme_id: theme.id)
          end
        end
      end
    end
  end
end
