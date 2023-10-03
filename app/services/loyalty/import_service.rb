module Loyalty
  class ImportService
    METAFIELD_UPDATE_DELAY = 0.5

    def initialize(shop:, import_data:, mapping:, col_sep:, import_action:)
      @shop = shop
      @import_data = import_data
      @mapping = mapping
      @col_sep = col_sep
      @import_action = import_action
      @errors = []
      @count = 0
      @batch = Sidekiq::Batch.new
      @last_id = @shop.loyalty_events.import.last&.id || 0
      @total_processed = 0
    end

    def call
      @batch.description = "Loyalty import for shop #{@shop.id}"

      @batch.jobs do
        CSV.parse(@import_data, headers: true, col_sep: @col_sep).each_with_index do |row, index|
          @total_processed = index + 1

          # ensure that customer_id is integer and not some random string or else postgress will break
          # example of bad customer_id '6.15142E+12'
          customer_external_id = row[@mapping['customer_id']].to_i

          customer = @shop.customers.find_by(email: row[@mapping['email']].strip) if row[@mapping['email']].present?
          customer ||= @shop.customers.find_by(external_id: customer_external_id) if customer_external_id > 0

          next add_customer_missing_error(row:, index:, customer:) if customer.blank?

          points = row[@mapping['points']].strip
          next add_points_wrong_format_error(row:, index:, points:) unless points.is_integer?

          points = points.to_i

          @count += 1

          Loyalty::ImportCustomerPointsJob.perform_async(
            shop_id: @shop.id,
            customer_id: customer.id,
            import_action: @import_action,
            points:,
            delay: @count * METAFIELD_UPDATE_DELAY
          )
        end
      end

      # if no jobs were scheduled the batch callbacks wont run
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

    def add_customer_missing_error(row:, index:, customer:)
      missing = []
      missing << 'customer info' unless customer

      row_data = row.map do |k, v|
        "#{k}: #{v}"
      end.join('<br>')

      @errors << "Row #{index + 1} is missing customer info. <br>#{row_data}"
    end

    def add_points_wrong_format_error(row:, index:, points:)
      @errors << "Row #{index + 1} has a wrong format of points: #{points}"
    end

    def add_sidekiq_batch_callback(notify: true)
      @batch.on(
        :success,
        Loyalty::ImportCallbackService,
        shop_id: @shop.id,
        bid: @batch.bid,
        errors: @errors,
        expected_count: @count,
        total_processed: @total_processed,
        last_id: @last_id,
        notify:,
        mapping: @mapping
      )
    end

    def complete_import
      Loyalty::ImportCallbackService.new.on_success(
        'error',
        {
          'shop_id' => @shop.id,
          'bid' => @batch.bid,
          'errors' => @errors,
          'expected_count' => @count,
          'total_processed' => @total_processed,
          'last_id' => @last_id,
          'notify' => true,
          'mapping' => @mapping
        }
      )
    end
  end
end
