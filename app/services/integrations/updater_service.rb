module Integrations
  class UpdaterService
    def call(shop:, integration_input:, integration: nil)
      @shop = shop
      ret = validate_input(integration_input:)

      return { error: ret[:error] } if ret[:error]

      widget_type = integration_input[:widget_type]
      key = integration_input[:key]
      integration ||= shop.integrations.where(widget_type:, key:).first_or_initialize

      default_settings = IntegrationConstants::ALL.dig(widget_type, key, :settings).to_h
      settings = default_settings.deep_merge(integration_input[:settings])

      if integration_input[:enabled] || integration.persisted?
        update_params = {
          disabled_at: integration_input[:enabled] ? nil : Time.current
        }

        update_params[:settings] = integration_input[:settings] if update_settings(widget_type:, key:)
        integration.update(update_params)
      end

      { result: integration }
    end

    private

    def validate_input(integration_input:)
      return {} unless integration_input[:enabled]

      case integration_input[:widget_type]
      when Integration::CUSTOMER_PAGE_TYPE
        return { error: 'Integrations plugin is not enabled. Please enable the plugin' } unless @shop.cp_integrations_active?

        validate_customer_page_integration_input(integration_input:)
      when Integration::WISHLIST_TYPE
        validate_wishlist_integration_input(integration_input:)
      when Integration::LOYALTY_TYPE
        validate_loyalty_integration_input(integration_input:)
      else
        error = "Integration type: #{integration_input[:widget_type]} not supported please reload the page and try again"
        Utils::RollbarService.error(error, shop_id: @shop.id)
        { error: }
      end
    end

    def validate_wishlist_integration_input(integration_input:)
      case integration_input[:key]
      when IntegrationConstants::KLAVIYO
        return { error: 'Klaiyo requires Wishlist Premium Plan. Please upgrade the plan.' } unless @shop.wishlist_premium_active?

        if integration_input[:settings]['public_api_key'].blank?
          return { error: "Settings for #{integration_input[:key].capitalize} are not valid. Please add a value for 'Public Api Key'" }
        end

        {}

      when IntegrationConstants::FACEBOOK_PIXEL
        return { error: 'Facebook Pixel requires Wishlist Premium Plan. Please upgrade the plan.' } unless @shop.wishlist_premium_active?

        {}
      when IntegrationConstants::GOOGLE_ANALYTICS
        return { error: 'Google Analytics requires Wishlist Premium Plan. Please upgrade the plan.' } unless @shop.wishlist_premium_active?

        {}
      else
        error = "Integration key: #{integration_input[:key]} not supported for Wishlist integrations. Please reload the page and try again"
        Utils::RollbarService.error(error, shop_id: @shop.id)
        { error: }
      end
    end

    def validate_customer_page_integration_input(integration_input:)
      case integration_input[:key]
      when IntegrationConstants::YOTPO_REWARDS
        return { error: 'Widget code is required for Yotpo Loyalty & Rewards' } if integration_input[:settings]['widget_code'].blank?
        return { error: 'Account page path is required for Yotpo Loyalty & Rewards' } if integration_input[:settings]['path'].blank?
      when IntegrationConstants::YOTPO_SUBSCRIPTIONS
        return { error: 'Account page path is required for Yotpo Subscriptions' } if integration_input[:settings]['path'].blank?
      when IntegrationConstants::RIVO_REWARDS
        return { error: 'Account page path is required for Rivo Loyalty & Referrals' } if integration_input[:settings]['path'].blank?
      when IntegrationConstants::PAY_WHIRL_SUBSCRIPTIONS
        return { error: 'Account page path is required for PayWhirl Subscription Payments' } if integration_input[:settings]['path'].blank?
      when IntegrationConstants::PARCEL_PANEL
        return { error: 'Account page path is required for Parcel Panel Order Tracking' } if integration_input[:settings]['path'].blank?
      when IntegrationConstants::WISHLIST_WISHIFY
        return { error: 'Account page path is required for Wishlist ‑ Wishify' } if integration_input[:settings]['path'].blank?
      when IntegrationConstants::SENDOWL_DOWNLOAD
        return { error: 'Store id is required for Sendowl' } if integration_input[:settings]['sendowl_store_id'].blank?
      when IntegrationConstants::AFTERSHIP_RETURNS
        if integration_input[:settings]['embedded'] && integration_input[:settings]['embedded_url'].blank?
          return { error: 'AfterShip Returns Center embedded url cannot be empty' }
        end
        if !integration_input[:settings]['embedded'] && integration_input[:settings]['external_url'].blank?
          return { error: 'AfterShip Returns Center external url cannot be empty' }
        end
      end

      {}
    end

    def update_settings(widget_type:, key:)
      IntegrationConstants::ALL.dig(widget_type, key, :dont_save_settings) ? false : true
    end

    def validate_loyalty_integration_input(integration_input:)
      return { error: 'Loyalty plugin is not enabled. Please enable and try again' } unless @shop.loyalty_active?

      case integration_input[:key]
      when IntegrationConstants::LOYALTY_JUDGEME
        return { error: 'Judge.me Product Reviews requires at least Loyalty 500 orders plan.' } if @shop.loyalty_first?
      else
        error = "Integration key: #{integration_input[:key]} not supported for Wishlist integrations. Please reload the page and try again"
        Utils::RollbarService.error(error, shop_id: @shop.id)
        { error: }
      end

      {}
    end
  end
end
