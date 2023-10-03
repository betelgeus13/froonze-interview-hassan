module Mutations
  module Admin
    class UpdateShopifyThemeAsset < BaseMutation
      argument :shop_id, ID, required: true
      argument :theme_id, ID, required: true
      argument :asset_key, String, required: true
      argument :value, String, required: true

      field :error, String, null: true

      def resolve(_params)
        {}
        #   shop = Shop.find_by(id: params[:shop_id])
        #   return { error: 'Shop not found' } if shop.blank?
        #   return { error: 'Shop is not installed' } unless shop.installed?
        #   theme = shop.shopify_themes.find_by(id: params[:theme_id])
        #   return { error: 'Theme not found' } if theme.blank?

        #   shop.with_shopify_session do
        #     asset = ShopifyAPI::Asset.find(params[:asset_key], params: { theme_id: theme.external_id })
        #     asset.value = params[:value]
        #     asset.save!
        #   end
        #   {}
        # rescue ActiveResource::ResourceNotFound
        #   { error: 'File not found' }
        # rescue ActiveResource::UnauthorizedAccess => exception
        #   { error: 'Shop seems to be uninstalled' }
        # rescue ActiveResource::TimeoutError => exception
        #   { error: 'Time out error' }
        # rescue ::ActiveResource::ClientError => exception
        #   if exception.message.squish.include?('Response code = 429. Response message = Too Many Requests.')
        #     { error: 'There are too many requests' }
        #   else
        #     { error: exception.to_s }
        #   end
      end
    end
  end
end
