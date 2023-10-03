module Types
  module Admin
    class ShopifyThemeType < Types::BaseObject

      LIST_ASSET_FIELDS = %w(key content_type).freeze
      INDIVIDUAL_ASSET_FIELDS = %w(key content_type value).freeze

      field :id, ID, null: false
      field :external_id, String, null: false
      field :name, String, null: false
      field :live, Boolean, null: false
      field :global, Boolean, null: false
      field :shopify_theme_customizations, [Types::Admin::ShopifyThemeCustomizationType], null: false
      field :assets, [Types::Admin::ShopifyThemeAssetType], null: false
      field :asset, Types::Admin::ShopifyThemeAssetType, null: false do
        argument :asset_key, String, required: true
      end

      def live
        object.live?
      end

      def global
        object.global_customization?
      end

      def shopify_theme_customizations
        AssociationLoader.for(object.class, :shopify_theme_customizations).load(object)
      end

      def assets
        object.shop.with_shopify_session do
          ShopifyAPI::Asset.all(params: { theme_id: object.external_id, fields: LIST_ASSET_FIELDS })
        end
      end

      def asset(asset_key:)
        object.shop.with_shopify_session do
          ShopifyAPI::Asset.find(asset_key, params: { theme_id: object.external_id, fields: INDIVIDUAL_ASSET_FIELDS })
        end
      end

    end
  end
end
