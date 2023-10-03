module Types
  module Admin
    class ShopifyThemeCustomizationType < Types::BaseObject
      graphql_name 'ShopifyThemeCustomization'

      field :customization_type, String, null: false
      field :html, String, null: true
      field :css, String, null: true
      field :js, String, null: true

    end
  end
end
