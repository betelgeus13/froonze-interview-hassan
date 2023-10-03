# frozen_string_literal: true

module Products
  class FactoryService
    def initialize(shop:)
      @shop = shop
    end

    def call(shopify_product:, product: nil)
      ret = Products::ProductParamsService.new.call(shopify_product:, shop_id: @shop.id)
      return ret if ret[:error]

      product ||= @shop.products.find_by(external_id: shopify_product.id)
      product ||= @shop.products.find_by(handle: shopify_product.handle)
      product ||= @shop.products.new

      product.update(ret[:product_params])

      { product: }
    rescue ActiveRecord::RecordNotUnique => e
      Products::DeduplicateService.new.call(shop: @shop, shopify_product:)
    end
  end
end
