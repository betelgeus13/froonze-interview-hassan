# frozen_string_literal: true

module Products
  class BulkFactory
    def call(shop:, shopify_products:)
      product_handles = shopify_products.map(&:handle)
      existing_products = shop.products.where(handle: product_handles).index_by(&:handle)

      new_product_data = []
      existing_product_data = []
      shopify_products.each do |shopify_product|
        product_params = Products::ProductParamsService.new.call(shopify_product: shopify_product, shop_id: shop.id)[:product_params]

        if existing_products[shopify_product.handle].present?
          product_params[:id] = existing_products[shopify_product.handle].id
          product_params[:created_at] = existing_products[shopify_product.handle].created_at
          existing_product_data << product_params
          next
        end

        new_product_data << product_params
      end

      Product.insert_all(new_product_data) if new_product_data.present? && ProductPolicies::Create.new(shop: shop).allowed?(new_products_count: new_product_data.count)
      Product.upsert_all(existing_product_data) if existing_product_data.present?

      Shop.update_counters shop.id, products_count: new_product_data.count
    end
  end
end
