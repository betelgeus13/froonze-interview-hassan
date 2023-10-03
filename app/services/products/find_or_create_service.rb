module Products
  class FindOrCreateService
    def initialize(shop:)
      @shop = shop
    end

    def call(handle:, external_id:)
      product = @shop.products.find_by(handle: handle)

      return { product: product } if product.present?
      return { error: 'Products limit exceeded. Cannot create a new product.' } unless ProductPolicies::Create.new(shop: @shop).allowed?

      shopify_product = get_shopify_product(external_id: external_id, handle: handle)
      return { error: "Cannot find a product with handle: #{handle} or product id: #{external_id}" } if shopify_product.blank?

      ret = Products::FactoryService.new(shop: @shop).call(shopify_product: shopify_product)
      return { error: ret[:error] } if ret[:error]

      { product: ret[:product] }
    rescue StandardError => e
      Utils::RollbarService.error(e)
      { error: 'Something went wrong. Please reload the page and try again' }
    end

    private

    def get_shopify_product(external_id:, handle:)
      @shop.with_shopify_session do
        shopify_product = ShopifyAPI::Product.find(external_id) if external_id
        shopify_product ||= ShopifyAPI::Product.where(handle: handle).first
        shopify_product
      rescue StandardError => e
        Utils::RollbarService.error(e, shop_id: @shop.id, handle: handle, product_external_id: external_id)
        nil
      end
    end
  end
end
