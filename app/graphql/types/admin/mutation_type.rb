module Types
  module Admin
    class MutationType < Types::BaseObject
      field :update_shopify_theme_customization, mutation: Mutations::Admin::UpdateShopifyThemeCustomization
      field :update_shopify_theme_asset, mutation: Mutations::Admin::UpdateShopifyThemeAsset
    end
  end
end
