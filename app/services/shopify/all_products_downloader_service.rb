# frozen_string_literal

module Shopify
  class AllProductsDownloaderService
    SHOPIFY_PER_PAGE_LIMIT = 250
    PAGES_PER_JOB = 3
    RETRY_TIMES = 5
    PAGE_COUNT_BEFORE_WAIT = 9
    WAIT_TIME = 1.second.freeze

    def initialize(shop:, next_page_info: nil, downloaded_page_counter: 0, retry_counter: 0)
      @shop = shop
      @next_page_info = next_page_info
      @retry_counter = retry_counter.to_i # per job retry counter
      @downloaded_page_counter = downloaded_page_counter.to_i
    end

    def call
      fetch_and_save_products
      schedule_next_job if @next_page_info
    rescue ActiveResource::ClientError
      retry_or_fail
    end

    private

    def fetch_and_save_products
      @shop.with_shopify_session do
        PAGES_PER_JOB.times do
          products = fetch_next_page_products
          Products::BulkFactory.new.call(shop: @shop, shopify_products: products)
          @downloaded_page_counter += 1
          @next_page_info = products.next_page_info
          break unless @next_page_info
        end
      end
    end

    def fetch_next_page_products
      ShopifyAPI::Product.find(:all, params: { fields: WebhooksConstants::PRODUCT_FIELDS, limit: SHOPIFY_PER_PAGE_LIMIT, page_info: @next_page_info }.compact)
    end

    def retry_or_fail
      @retry_counter += 1
      if @retry_counter >= RETRY_TIMES
        raise "Retry limit of #{RETRY_TIMES} reached"
      else
        Shopify::AllProductsDownloaderJob.perform_in(WAIT_TIME, shop_id: @shop.id, next_page_info: @next_page_info, downloaded_page_counter: @downloaded_page_counter, retry_counter: @retry_counter) # send this job to scheduled queue
      end
    end

    def schedule_next_job
      if @downloaded_page_counter % PAGE_COUNT_BEFORE_WAIT == 0
        Shopify::AllProductsDownloaderJob.perform_in(WAIT_TIME, shop_id: @shop.id, next_page_info: @next_page_info, downloaded_page_counter: @downloaded_page_counter) # send this job to scheduled queue for monitoring purpose. If all jobs go to default queue, it's going to be impossible to detect errors if a job keeps running forever for some reason
      else
        Shopify::AllProductsDownloaderJob.perform_async(shop_id: @shop.id, next_page_info: @next_page_info, downloaded_page_counter: @downloaded_page_counter)
      end
    end
  end
end
