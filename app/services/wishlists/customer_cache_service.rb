module Wishlists
  class CustomerCacheService
    def call(customer:)
      wishlist_items = customer.wishlist_items.active.preload(:product)

      lists = wishlist_items.each_with_object({}) do |item, hash|
        next unless item.product.in_store?

        hash[item.list] ||= {}
        hash[item.list][item.product.handle] ||= []
        hash[item.list][item.product.handle] << item.variant_external_id.to_i
      end

      shared_wishlist_slugs = {}
      # cache in shared_wishlist
      shared_wishlist = customer.shared_wishlists.find_each do |shared_wishlist|
        shared_wishlist_slugs[shared_wishlist.list] = shared_wishlist.slug
        shared_wishlist.update(items: lists[shared_wishlist.list] || {})
      end

      # cache in metafields
      Shopify::Metafields::WishlistUpdaterService.new.call(
        shop: customer.shop,
        customer_external_id: customer.external_id,
        active_wishlist_list: customer.active_wishlist_list_with_default,
        list_names: customer.wihslist_lists_with_default,
        lists:,
        shared_wishlist_slugs:
      )
    end
  end
end
