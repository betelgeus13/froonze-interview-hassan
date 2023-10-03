module Shopify
  class PagesFetcherService

    class FetchingError < StandardError; end

    SHOPIFY_PER_PAGE_LIMIT = 250

    ATTRIBUTES = [:id, :title, :handle].freeze

    def initialize(shop)
      @shop = shop
    end

    def call
      pages = Rails.cache.fetch("shop:#{@shop.id}__pages", expires_in: 10.minutes) do
        @shop.with_shopify_session do
          result = ShopifyAPI::Page.all(params: { limit: SHOPIFY_PER_PAGE_LIMIT })
          result = result.select(&:published_at)
          result.map { |page| page.attributes.slice(*ATTRIBUTES) }
        end
      end
      pages.map { |page| OpenStruct.new(page) }
    end

  end
end
