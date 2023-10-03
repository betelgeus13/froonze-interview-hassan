# frozen_string_literal: true

module Integrations
  module Klaviyo
    class BroadcastWishlistEventService
      EVENT_PREFIX = 'Froonze'
      def call(integration:, wishlist_item:, event_name:, value:)
        return { error: 'Shop not active' } unless integration.shop.installed?
        return { error: 'No customer' } if wishlist_item.customer.blank?

        value = value ? value.to_i / 100 : nil
        track_payload = {
          token: integration.settings['public_api_key'],
          event: "#{EVENT_PREFIX}-#{event_name.camelize}",
          customer_properties: {
            '$email' => wishlist_item.customer.email
          },
          properties: {
            event_time: Time.current,
            product_handle: wishlist_item.product.handle,
            product_title: wishlist_item.product.title,
            product_image_url: wishlist_item.product.picture_url,
            variant_price: wishlist_item.product.variants.dig(wishlist_item.variant_external_id.to_s, 'price').to_f,
            variant_id: wishlist_item.variant_external_id,
            '$value' => value
          }.compact
        }

        Integrations::Klaviyo::TrackApi.new.call(track_payload:)
      end
    end
  end
end
