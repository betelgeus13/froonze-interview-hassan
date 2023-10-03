module Types
  module Admin
    class ShopifyThemeAssetType < Types::BaseObject

      field :key, String, null: false
      field :content_type, String, null: false
      field :value, String, null: true

    end
  end
end
