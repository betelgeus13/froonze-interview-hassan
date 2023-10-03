module Wishlists
  class ImportService
    def initialize(shop:, import_data:, mapping:, col_sep:)
      @shop = shop
      @import_data = import_data
      @mapping = mapping
      @col_sep = col_sep
      @errors = []
      @count = 0
      @batch = Sidekiq::Batch.new
      @last_id = @shop.wishlist_items.order(id: :desc).first&.id.to_i
      @total_processed = 0
    end

    def call
      @batch.description = "Wishlist import for shop #{@shop.id}"

      @batch.jobs do
        CSV.parse(@import_data, headers: true, col_sep: @col_sep).each_with_index do |row, index|
          @total_processed = index

          # ensure that customer_id and product_id is integer and not some random string or else postgress will break
          # example of bad customer/product id '6.15142E+12'
          customer_external_id = row[@mapping['customer_id']].to_i
          product_external_id = row[@mapping['product_id']].to_i

          customer = @shop.customers.find_by(email: row[@mapping['email']].strip) if row[@mapping['email']].present?
          customer ||= @shop.customers.find_by(external_id: customer_external_id) if customer_external_id > 0
          product = @shop.products.find_by(handle: row[@mapping['handle']].strip) if row[@mapping['handle']].present?
          product ||= @shop.products.find_by(external_id: product_external_id) if product_external_id > 0

          next add_error(row: row, index: index + 1, customer: customer, product: product) if customer.blank? || product.blank?

          variant_external_id = row[@mapping['variant_id']]
          variant_external_id = nil if variant_external_id && product.variants[variant_external_id.to_s].nil?
          variant_external_id ||= product.variants.keys.first

          @count += 1

          Wishlists::ImportWishlistItemJob.perform_async(
            shop_id: @shop.id,
            customer_id: customer.id,
            product_id: product.id,
            variant_external_id: variant_external_id.to_s
          )
        end
      end

      # if no jobs where scheduled the batch callbacks wont run
      @count > 0 ? add_sidekiq_batch_callback : complete_import
      {}
    rescue StandardError => e
      @errors << "When processing the csv we encountered the following error: #{e.message}"

      complete_import
      add_sidekiq_batch_callback(notify: false) if @count > 0

      Utils::RollbarService.error(e, shop_id: @shop.id)

      { error: e.message }
    end

    private

    def add_error(row:, index:, customer:, product:)
      missing = []
      missing << 'product info' unless product
      missing << 'customer info' unless customer

      row_data = row.map do |k, v|
        "#{k}: #{v}"
      end.join('<br>')

      @errors << "Row #{index} is missing: #{missing.join(' and ')}<br>#{row_data}"
    end

    def add_sidekiq_batch_callback(notify: true)
      @batch.on(
        :success, Wishlists::ImportCallbacks,
        shop_id: @shop.id,
        bid: @batch.bid,
        errors: @errors,
        expected_count: @count,
        total_processed: @total_processed + 1,
        last_id: @last_id,
        notify: notify,
        mapping: @mapping
      )
    end

    def complete_import
      Wishlists::ImportCallbacks.new.on_success(
        'error',
        {
          'shop_id' => @shop.id,
          'bid' => @batch.bid,
          'errors' => @errors,
          'expected_count' => @count,
          'total_processed' => @total_processed + 1,
          'last_id' => @last_id,
          'notify' => true,
          'mapping' => @mapping
        }
      )
    end
  end
end
