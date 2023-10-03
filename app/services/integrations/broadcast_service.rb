module Integrations
  class BroadcastService
    def initialize(shop:)
      @shop = shop
      @integrations = {}
    end

    def on_wishlist_add_multiple_items(wishlist_items:)
      return {} unless broadcast?(event_name: BroadcastEventConstants::WISHLIST_ADDED)

      wishlist_items.each do |wishlist_item|
        event_data = {
          wishlist_item_id: wishlist_item.id
        }
        on_event(event_name: BroadcastEventConstants::WISHLIST_ADDED, event_data:)
      end
      {}
    end

    def on_wishlist_add(wishlist_item:)
      return {} unless broadcast?(event_name: BroadcastEventConstants::WISHLIST_ADDED)

      event_data = {
        wishlist_item_id: wishlist_item.id
      }
      on_event(event_name: BroadcastEventConstants::WISHLIST_ADDED, event_data:)
    end

    def on_wishlist_remove(wishlist_item:)
      return {} unless broadcast?(event_name: BroadcastEventConstants::WISHLIST_REMOVED)

      event_data = {
        wishlist_item_id: wishlist_item.id
      }
      on_event(event_name: BroadcastEventConstants::WISHLIST_REMOVED, event_data:)
    end

    def on_wishlist_add_to_cart(wishlist_item:, value:)
      return {} unless broadcast?(event_name: BroadcastEventConstants::WISHLIST_ADDED_TO_CART)

      event_data = {
        wishlist_item_id: wishlist_item.id,
        value:
      }
      on_event(event_name: BroadcastEventConstants::WISHLIST_ADDED_TO_CART, event_data:)
    end

    def on_wishlist_bought(wishlist_item:, value:)
      return {} unless broadcast?(event_name: BroadcastEventConstants::WISHLIST_BOUGHT)

      event_data = {
        wishlist_item_id: wishlist_item.id,
        value:
      }
      on_event(event_name: BroadcastEventConstants::WISHLIST_BOUGHT, event_data:)
    end

    def on_event(event_name:, event_data:)
      broadcast_integrations(event_name:, event_data:)

      {}
    end

    def broadcast_integrations(event_name:, event_data:)
      integrations = get_integrations(event_name:)

      integrations.each do |integration|
        case integration.key
        when IntegrationConstants::KLAVIYO
          Integrations::Klaviyo::BroadcastJob.perform_async(integration_id: integration.id, event_name:, event_data:)
        end
      end
    end

    def broadcast?(event_name:)
      get_integrations(event_name:).present?
    end

    def get_integrations(event_name:)
      return @integrations[event_name] unless @integrations[event_name].nil?

      @integrations[event_name] = @shop.integrations.enabled.where("settings#>>'{events,#{event_name}}' = ?", 'true')
      @integrations[event_name]
    end
  end
end
