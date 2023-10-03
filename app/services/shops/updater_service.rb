module Shops
  class UpdaterService
    APP_PROXY = 'app_proxy'
    SHOPIFY_PLAN = 'shopify_plan'
    ACCEPTS_MARKETING = 'accepts_marketing'

    def call(shop:, params:)
      shop.update!(**params)

      {}
    end

    def self.run_callbacks(shop:)
      changes = shop.previous_changes.keys.to_set

      Shopify::Metafields::AppProxyUpdaterJob.perform_async(shop_id: shop.id) if changes.include?(APP_PROXY)
      Sendinblue::ContactManagerJob.perform_async(shop.id) if changes.include?(SHOPIFY_PLAN) || changes.include?(ACCEPTS_MARKETING)
    end
  end
end
