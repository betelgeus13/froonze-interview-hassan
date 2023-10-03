module Types
  module Admin
    class ShopifyThemeCustomizationInputType < Types::BaseInputObject

      argument :customization_type, String, required: true
      argument :html, String, required: false
      argument :css, String, required: false
      argument :js, String, required: false

    end
  end
end
