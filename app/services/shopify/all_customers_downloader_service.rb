# frozen_string_literal

module Shopify
  class AllCustomersDownloaderService
    SHOPIFY_PER_PAGE_LIMIT = 250
    PAGES_PER_JOB = 3
    RETRY_TIMES = 5
    PAGE_COUNT_BEFORE_WAIT = 9
    WAIT_TIME = 1.second.freeze

    def initialize(shop, next_page_info = nil, downloaded_page_counter = 0, retry_counter = 0)
      @shop = shop
      @next_page_info = next_page_info
      @retry_counter = retry_counter # per job retry counter
      @downloaded_page_counter = downloaded_page_counter
      @customer_factory = Customers::FactoryService.new(shop: @shop)
    end

    def call
      fetch_and_save_customers
      schedule_next_job if @next_page_info
    rescue ActiveResource::ClientError
      retry_or_fail
    end

    private

    def fetch_and_save_customers
      @shop.with_shopify_session do
        PAGES_PER_JOB.times do
          customers = fetch_next_page_customers
          save_customers(customers)
          @downloaded_page_counter += 1
          @next_page_info = customers.next_page_info
          break unless @next_page_info
        end
      end
    end

    def fetch_next_page_customers
      if @next_page_info
        ShopifyAPI::Customer.find(:all,
                                  params: { fields: WebhooksConstants::CUSTOMER_FIELDS, limit: SHOPIFY_PER_PAGE_LIMIT,
                                            page_info: @next_page_info })
      else
        ShopifyAPI::Customer.find(:all, params: { fields: WebhooksConstants::CUSTOMER_FIELDS, limit: SHOPIFY_PER_PAGE_LIMIT })
      end
    end

    def retry_or_fail
      @retry_counter += 1
      raise "Retry limit of #{RETRY_TIMES} reached" if @retry_counter >= RETRY_TIMES

      Shopify::AllCustomersDownloaderJob.perform_in(WAIT_TIME, @shop.id, @next_page_info, @downloaded_page_counter, @retry_counter) # send this job to scheduled queue
    end

    def save_customers(shopify_customers)
      customer_external_ids = shopify_customers.map(&:id)

      shopify_customers.each do |shopify_customer|
        customer_params = Customers::CustomerParamsService.new.call(shopify_customer:)[:customer_params]
        @customer_factory.create_or_update(params: customer_params)
      end
    end

    def schedule_next_job
      if need_to_wait?
        Shopify::AllCustomersDownloaderJob.perform_in(WAIT_TIME, @shop.id, @next_page_info, @downloaded_page_counter) # send this job to scheduled queue for monitoring purpose. If all jobs go to default queue, it's going to be impossible to detect errors if a job keeps running forever for some reason
      else
        Shopify::AllCustomersDownloaderJob.perform_async(@shop.id, @next_page_info, @downloaded_page_counter)
      end
    end

    def need_to_wait?
      @downloaded_page_counter % PAGE_COUNT_BEFORE_WAIT == 0
    end
  end
end
