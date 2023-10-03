module Integrations
  class FetcherService
    def initialize(shop)
      @shop = shop
    end

    def call(widget_type:)
      existing_integrations_mapping = @shop.integrations.where(widget_type:).index_by(&:key)
      IntegrationConstants::ALL[widget_type].map do |key, info|
        data = info.dup
        data[:key] = key
        data[:widget_type] = widget_type
        data[:enabled] = existing_integrations_mapping[key]&.enabled? || false
        data[:is_nav_item] ||= false

        # ensure that new settings are added
        data[:settings] = public_settings(info:, existing_integrations_mapping:, key:, widget_type:)

        data
      end
    end

    private

    def public_settings(info:, existing_integrations_mapping:, key:, widget_type:)
      settings = info[:settings].to_h.merge(existing_integrations_mapping[key]&.settings.to_h)
      if widget_type == Integration::LOYALTY_TYPE && key == IntegrationConstants::LOYALTY_JUDGEME
        settings = {
          webhook_installed: settings.dig('webhooks', 'review/created', 'url').present?,
          error: settings.dig('webhooks', 'review/created', 'error'),
          authenticated: settings['access_token'].present?
        }
      end

      settings
    end
  end
end
