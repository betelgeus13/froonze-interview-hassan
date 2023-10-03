# frozen_string_literal: true
module Settings
  class SocialLoginsFetcherService

    def initialize(setting)
      @setting = setting
    end

    def providers
      saved_providers = @setting.social_logins_providers
      if saved_providers.empty?
        default = SocialLoginsConstants::DEFAULT_PROVIDERS.map { |provider_name| provider_object(provider_name, true) }
        other = SocialLoginsConstants::OTHER_PROVIDERS.map { |provider_name| provider_object(provider_name, false) }
        default + other
      else
        process_saved_providers(saved_providers)
      end
    end

    def customer_tags
      @setting.social_logins_customer_tags || SocialLoginsConstants::DEFAULT_CUSTOMER_TAGS
    end

    def google_one_tap
      settings = @setting.social_logins_google_one_tap
      settings['margin_top'] ||= SocialLoginsConstants::GOOGLE_ONE_TAP_MARGIN_TOP_DEFAULT
      settings['margin_right'] ||= SocialLoginsConstants::GOOGLE_ONE_TAP_MARGIN_RIGHT_DEFAULT
      settings
    end

    private

    def provider_object(name, enabled)
      {
        'name' => name,
        'enabled' => enabled,
      }
    end

    def process_saved_providers(saved_providers)
      saved_providers = saved_providers.each_with_object([]) do |(provider_name, settings), list|
        settings['name'] = provider_name
        list << settings
      end
      saved_providers = saved_providers.sort_by { |provider| provider['order'] }
      saved_provider_names = saved_providers.map { |provider| provider['name'] }
      missing_provider_names = SocialLoginsConstants::ALL_PROVIDERS - saved_provider_names
      missing_providers = missing_provider_names.map { |provider_name| provider_object(provider_name, false) }
      saved_providers + missing_providers
    end

  end
end
