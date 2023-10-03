require 'securerandom'

module Wishlists
  class ShareService
    def call(shop:, customer:, items:, list:)
      list ||= WishlistConstants::DEFAULT_LIST
      shared_wishlist = customer.shared_wishlists.find_by(list: list)

      return { slug: shared_wishlist.slug } if shared_wishlist

      shared_wishlist = shop.shared_wishlists.new
      shared_wishlist.customer = customer

      shared_wishlist.items = items
      shared_wishlist.slug = SecureRandom.urlsafe_base64(12)
      shared_wishlist.list = list
      shared_wishlist.save!

      Wishlists::CustomerCacheJob.perform_async(shop_id: shop.id, customer_id: customer.id)
      { slug: shared_wishlist.slug }
    rescue ActiveRecord::RecordNotUnique => e
      shared_wishlist.slug = SecureRandom.urlsafe_base64(12)

      begin
        shared_wishlist.save!
        Wishlists::CustomerCacheJob.perform_async(shop_id: shop.id, customer_id: customer.id)
        { slug: shared_wishlist.slug }
      rescue StandardError => e
        { error: 'Something went wrong please try again later' }
      end
    end
  end
end
