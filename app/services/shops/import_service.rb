module Shops
  class ImportService
    IMPORT_TYPES = Set[
      WISHLIST = 'wishlist',
      LOYALTY = 'loyalty',
    ].freeze

    def initialize(shop:, import_type:, s3_key:, mapping:, col_sep:, options: {})
      @shop = shop
      @import_type = import_type
      @s3_key = s3_key
      @mapping = mapping
      @col_sep = col_sep
      @options = options
      @key = "import:#{shop.id}:#{import_type}"
    end

    def schedule_job
      return { error: 'Another import is in progress' } if in_progress?
      return { error: 'Mapping is empty. Please reload the page and try again.' } if @mapping.blank?
      return { error: 'Import type is not supported' } unless IMPORT_TYPES.include?(@import_type)
      return { error: 'Mapping is missing fields. Please check that all required fields are selected.' } unless valid_mapping?

      add_lock
      Shops::ImportJob.perform_async(
        shop_id: @shop.id,
        import_type: @import_type,
        s3_key: @s3_key,
        mapping: @mapping,
        col_sep: @col_sep,
        options: @options,
      )

      {}
    end

    def call
      ret = Utils::FetchS3FileService.new(s3_key: @s3_key, bucket: Rails.application.credentials.aws[:buckets][:import]).call
      if ret[:error]
        remove_lock
        send_file_error_email(@import_type, ret[:error])
        return { error: ret[:error] }
      end

      import_data = sanitize_data(ret[:result])

      case @import_type
      when WISHLIST
        Wishlists::ImportService.new(shop: @shop, import_data:, mapping: @mapping, col_sep: @col_sep).call
      when LOYALTY
        Loyalty::ImportService.new(shop: @shop, import_data: ret[:result], mapping: @mapping, col_sep: @col_sep, import_action: @options['import_action']).call
      else
        error = "#{@import_type} is not supported for #{self.class.name}"
        Utils::RollbarService.error(error)
        { error: error }
      end
    end

    def remove_lock
      $redis.del(@key)
    end

    private

    def add_lock
      $redis.set(@key, 15.minutes.from_now, nx: false, ex: 15.minutes)
    end

    def valid_mapping?
      case @import_type
      when WISHLIST
        (@mapping['email'] || @mapping['customer_id']) && (@mapping['handle'] || @mapping['product_id'])
      when LOYALTY
        (@mapping['email'] || @mapping['customer_id']) && @mapping['points']
      else
        error = "#{@import_type} is not supported for #{self.class.name}"
        Utils::RollbarService.error(error)
        false
      end
    end

    def in_progress?
      $redis.get(@key).present?
    end

    def sanitize_data(data)
      data = data.scrub
      data = data.gsub("\r\n", "\r") # Windows row_sep
      data = data.gsub("\r\r", "\r")
      data = data.tr("\n", "\r") # Quoted fields may contain \n but the parser can only handle one type of row_sep.
      data = data.force_encoding('UTF-8')
      data = data.sub("\xEF\xBB\xBF".force_encoding('UTF-8'), '') # remove BOM, the r:bom doesn't work, no idea why
      data = data.tr("\u00A0", ' ') # replace non-breaking white space as these are not removed by #strip
      data = data.delete("\u0000")
      data
    end

    def send_file_error_email(import_type, error)
      ShopMailer.import_completed(
        import_type:,
        shop: @shop,
        import_count: 0,
        expected_count: 0,
        total_processed: 0,
        errors: ["While fetching the file '#{@s3_key}' content we encountered the following error: #{error}"],
        mapping: @mapping
      ).deliver_now
    end
  end
end
