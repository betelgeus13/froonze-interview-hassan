# frozen_string_literal: true
module Loyalty
  class ImportCallbackService

    def on_success(_status, options)
      shop = Shop.find(options['shop_id'])
      import_count = shop.loyalty_events
        .import
        .where('id > ?', options['last_id'].to_i)
        .count
      Shops::ImportService.new(shop:, import_type: Shops::ImportService::LOYALTY, s3_key: nil, mapping: nil, col_sep: nil).remove_lock

      return unless options['notify']

      ShopMailer.import_completed(
        shop:,
        import_count:,
        expected_count: options['expected_count'],
        import_type: Shops::ImportService::LOYALTY,
        total_processed: options['total_processed'],
        errors: options['errors'],
        mapping: options['mapping']
      ).deliver_now
    end

  end
end
