module Products
  class DeduplicateService
    def call(shop:, shopify_product:)
      ret = Products::ProductParamsService.new.call(shopify_product: shopify_product, shop_id: shop.id)
      return ret if ret[:error]

      product_params = ret[:product_params]

      by_external_id = shop.products.find_by(external_id: product_params[:external_id])
      by_handle = shop.products.find_by(handle: product_params[:handle])

      if by_handle.external_id.blank?
        move_wishlist_items_and_delete_by_handle_product(by_handle: by_handle, by_external_id: by_external_id, product_params: product_params)
      else
        shop.with_shopify_session do
          by_handle_in_shopify = ShopifyAPI::Product.find(by_handle.external_id)
          ret = Products::ProductParamsService.new.call(shopify_product: by_handle_in_shopify, shop_id: shop.id)
          return ret if ret[:error]

          by_handle_in_shopify_params = ret[:product_params]
          by_handle.update(by_handle_in_shopify_params)
          by_external_id.update(product_params)

        rescue ActiveResource::ResourceNotFound => e
          move_wishlist_items_and_delete_by_handle_product(by_handle: by_handle, by_external_id: by_external_id, product_params: product_params)
        end
      end

      { product: by_external_id }
    end

    private

    def move_wishlist_items_and_delete_by_handle_product(by_handle:, by_external_id:, product_params:)
      by_handle.wishlist_items.find_each do |wishlist_item|
        wishlist_item.update(product_id: by_external_id.id, source: WishlistItem::PRODUCT_CHANGE, variant_external_id: by_external_id.variants.keys.first)
      rescue ActiveRecord::RecordNotUnique => e
        existing_variant_ids = by_external_id.wishlist_items.where(customer_id: wishlist_item.customer_id).active.pluck(:variant_external_id)

        possible_variants_ids = by_external_id.variants.keys.map(&:to_i) - existing_variant_ids

        wishlist_item.update(product_id: by_external_id.id, source: WishlistItem::PRODUCT_CHANGE, variant_external_id: possible_variants_ids.first) if possible_variants_ids.present?
      end

      by_handle.destroy
      in_store_unchanged = product_params[:in_store] == by_external_id.in_store
      by_external_id.update(product_params)
      # need to run this only if by_external_id does not change it's in_sstore state

      Wishlists::UpdateMetafieldsForProductJob.perform_async(product_id: by_external_id.id) if in_store_unchanged
    end
  end
end
