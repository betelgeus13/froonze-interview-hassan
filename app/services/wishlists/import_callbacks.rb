module Wishlists
  class ImportCallbacks
    def on_success(_status, options)
      shop = Shop.find(options['shop_id'])
      new_imported = shop.wishlist_items.imported.where('id > ?', options['last_id'].to_i)
      total_imported = new_imported.count
      Shops::ImportService.new(shop:, import_type: Shops::ImportService::WISHLIST, s3_key: nil, mapping: nil, col_sep: nil).remove_lock

      # usually an import shouldnt have more than 5k rows and in most cases customers have more than 1 wishlist item
      new_imported.distinct.pluck(:customer_id).compact.each_with_index do |customer_id, index|
        delay = WishlistConstants::BULK_METAFIELD_UPDATES_DELAY * index
        Wishlists::CustomerCacheJob.perform_in(delay, shop_id: shop.id, customer_id:)
      end

      return unless options['notify']

      ShopMailer.import_completed(
        shop:,
        import_count: total_imported,
        expected_count: options['expected_count'],
        import_type: Shops::ImportService::WISHLIST,
        total_processed: options['total_processed'],
        errors: options['errors'],
        mapping: options['mapping']
      ).deliver_now
    end
  end
end
