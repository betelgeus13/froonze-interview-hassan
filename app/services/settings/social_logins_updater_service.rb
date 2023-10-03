# frozen_string_literal: true
module Settings
  class SocialLoginsUpdaterService

    PROVIDER_FIELDS = [:name, :enabled, :app_id, :app_secret].freeze
    APPLE_PROVIDER_FIELDS = (PROVIDER_FIELDS + [:apple_client_id, :apple_team_id]).freeze

    def initialize(shop, params)
      @shop = shop
      @params = params
      @providers = params[:providers]
      @customer_tags = params[:customer_tags]
      @google_one_tap = params[:google_one_tap]
      @multipass = params[:multipass]
      @accepts_email_marketing_default = params[:accepts_email_marketing_default]
    end

    def call
      return { error: 'Social Logins plugin is not enabled' } unless @shop.social_logins_active?

      update_settings = {
        social_logins_providers: generate_providers_hash,
        social_logins_customer_tags: generate_customer_tags,
        social_logins_accepts_email_marketing_default: @accepts_email_marketing_default,
        social_logins_forbid_registration: @params[:forbid_registration],
        social_logins_after_login_return_path: @params[:after_login_return_path],
        social_logins_after_registration_return_path: @params[:after_registration_return_path],
      }
      if @shop.social_logins_advanced_plan?
        update_settings[:social_logins_google_one_tap] = @google_one_tap
        update_settings[:social_logins_multipass] = @multipass
      end

      Settings::UpdaterService.new(@shop).update(update_settings)

      {}
    end

    private

    def generate_providers_hash
      providers_hash = {}
      @providers.each_with_index do |provider, index|
        providers_hash[provider.name] = provider_params(provider, index)
      end
      providers_hash
    end

    def provider_params(provider, index)
      is_apple = provider.name == 'apple'
      fields = is_apple ? APPLE_PROVIDER_FIELDS : PROVIDER_FIELDS
      provider_params = provider.to_hash.slice(*fields).merge(order: index)
      process_apple_params(provider_params) if is_apple
      provider_params
    end

    def generate_customer_tags
      if @customer_tags.sort == SocialLoginsConstants::DEFAULT_CUSTOMER_TAGS.sort
        nil
      else
        @customer_tags.first(SocialLoginsConstants::CUSTOMER_TAGS_LIMIT)
      end
    end

    def process_apple_params(params)
      params[:enabled] = false if !@shop.social_logins_advanced_plan?
      params[:app_secret] += "\n" if params[:app_secret].present? && !params[:app_secret].ends_with?("\n")
    end

  end
end
