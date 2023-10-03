module ShopifyThemes
  class FactoryService

    FIELDS = [
      :name,
      :role,
      :theme_store_id,
    ].freeze

    def initialize(shop: )
      @shop = shop
    end

    def create_or_update!(params:)
      theme = @shop.shopify_themes.find_or_initialize_by(external_id: params[:id])
      params = params.slice(*FIELDS)
      theme.update!(params)
      
      { theme: theme }
    end
  end
end
