module Shopify
  class OptionalWebhooksService
    def call(shop:)
      optional_webhooks = shop.optional_webhooks.to_a

      shop.with_shopify_session do
        registered_webhooks = ShopifyAPI::Webhook.all.index_by(&:topic)

        registered_optional_webhooks = registered_webhooks.select { |topic, _webhook| WebhooksConstants::OPTIONAL_WEBBOOK_TOPICS.include?(topic) }

        missing_webhooks = optional_webhooks - registered_optional_webhooks.keys
        to_delete_webhooks = registered_optional_webhooks.keys - optional_webhooks

        missing_webhooks.each do |topic|
          ShopifyAPI::Webhook.create(WebhooksConstants::OPTIONAL_HOOKS[topic].merge(topic: topic))
        end

        to_delete_webhooks.each do |topic|
          ShopifyAPI::Webhook.delete(registered_webhooks[topic].id)
        end
      end
      {}
    rescue StandardError => e
      Utils::RollbarService.error(e, shop_id: shop.id)
      { error: e }
    end
  end
end
