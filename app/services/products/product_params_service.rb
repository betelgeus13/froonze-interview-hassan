# frozen_string_literal: true

module Products
  class ProductParamsService
    def call(shopify_product:, shop_id:)
      variant_data = shopify_product.variants.each_with_object({}) do |variant, data|
        in_stock = variant.inventory_management != 'shopify' || # !Track quantity
                   variant.inventory_policy == 'continue' || # conntinue selling out of stock
                   variant.inventory_quantity.to_i > 0

        data[variant.id] = {
          compare_at_price: variant.compare_at_price,
          price: variant.price,
          in_stock:,
          quantity: variant.inventory_quantity.to_i
        }
      end

      product_params = {
        shop_id:,
        handle: shopify_product.handle,
        title: shopify_product.title,
        picture_url: shopify_product.images.first&.src,
        external_id: shopify_product.id,
        in_store: shopify_product.status == 'active' && shopify_product.published_at.present?,
        variants: variant_data,
        created_at: Time.current,
        updated_at: Time.current
      }

      { product_params: }
    end
  end
end
