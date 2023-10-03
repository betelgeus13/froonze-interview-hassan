module Integrations
  class AddDefaultSettingsService
    def self.call(integration:)
      default_settings = IntegrationConstants::ALL.dig(integration.widget_type, integration.key, :settings) || {}

      settings = default_settings.deep_merge(integration.settings)
      integration.update(settings: settings)
    end
  end
end
