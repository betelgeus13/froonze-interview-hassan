module Shops
  class SetOptionalWebhooksService
    def call(shop:)
      subscription = shop.active_shopify_subscription

      if subscription.blank?
        shop.update!(optional_webhooks: nil) if shop.optional_webhooks.present?
        return
      end

      optional_webhook_topics = subscription.plugins.each_with_object([]) do |(plugin, value), topics|
        topics.concat(WebhooksConstants::OPTIONAL_WEBHOOK_TOPICS_FOR_PLUGINS[plugin].to_a) if value
      end.uniq

      shop.update!(optional_webhooks: optional_webhook_topics.presence)

      {}
    end
  end
end
