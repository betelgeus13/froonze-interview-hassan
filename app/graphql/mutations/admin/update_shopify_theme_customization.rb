module Mutations
  module Admin
    class UpdateShopifyThemeCustomization < BaseMutation
      null false

      argument :shop_id, ID, required: true
      argument :shopify_theme_id, ID, required: true
      argument :shopify_theme_customization, Types::Admin::ShopifyThemeCustomizationInputType, required: true

      field :error, String, null: true

      def resolve(params)
        return {}
        # shop = Shop.find_by(id: params[:shop_id])
        # return { error: 'Could not find shop' } if shop.blank?
        # return { error: 'Shop is not installed' } unless shop.installed?
        # theme = shop.shopify_themes.find_by(id: params[:shopify_theme_id])
        # return { error: 'Could not find theme' } if theme.blank?
        # theme_customization = theme.shopify_theme_customizations.find_or_initialize_by(customization_type: params[:shopify_theme_customization][:customization_type])

        # ActiveRecord::Base.transaction do
        #   theme_customization.update!(params[:shopify_theme_customization].to_h)
        #   ThemeCustomizations::PublisherService.new(shop, theme_customization.customization_type).call
        # end

        # {}
      end

    end
  end
end
