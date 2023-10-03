module MerchantDashboard
  class DataService
    GLOBAL_CONSTANTS = {
      https_url: Rails.application.credentials.https_url,
      google_recaptcha_site_key: Rails.application.credentials.google_recaptcha_site_key,
      objects_per_page: Types::Merchant::ShopType::PER_PAGE,
      shopify_theme_app_extension_uuid: Rails.application.credentials.shopify_theme_app_extension_uuid,
      rollbar_access_token: Rails.application.credentials.rollbar[:merchant_dashboard_access_token],
      locales: WidgetTranslation::LOCALES,
      admin_locales: Shop::ADMIN_LOCALES,
      custom_pages_limit: CustomerPageConstants::CUSTOM_PAGES_LIMIT_PER_SHOP,
      social_logins: {
        customer_tags_limit: SocialLoginsConstants::CUSTOMER_TAGS_LIMIT
      },
      customer_page_integrations: IntegrationConstants::CUSTOMER_PAGE_INTEGRATIONS,
      custom_forms: {
        form_locations: Form.locations.keys,
        page_location_form_types: Form::PAGE_LOCATION_FORM_TYPES,
        custom_form_field_types: FormField::CUSTOM_TYPES,
        form_field_types_to_custom_field_types_mapping: FormField::CUSTOM_FIELD_TYPE_MAPPING,
        custom_field_types: CustomField.field_types.keys,
        custom_field_data_types: CustomField::DATA_TYPES_MAPPING,
        form_field_types_with_options: FormField::TYPES_WITH_OPTIONS,
        form_field_validation_operators: FormFieldValidation::OPERATORS,
        label_style_options: Form.label_styles.keys
      },
      shopify_api_key: ShopifyApp.configuration.api_key,
      loyalty: {
        event_types: LoyaltyEvent.event_types.keys,
        order_event_types: LoyaltyEvent::ORDER_TYPES,
        earning_rule_order_period_limit_units: LoyaltyEarningRule.order_period_limit_units.keys,
      }
    }.freeze

    def initialize(shop)
      @shop = shop
    end

    def shop_info
      @shop.update_monthly_orders_count if @shop.monthly_orders_count.blank?
      active_subscription = @shop.active_shopify_subscription
      subscription_manager = Shopify::Subscriptions::ManagerService.new(@shop, active_subscription&.plugins)
      info = {
        id: @shop.id,
        shopify_domain: @shop.shopify_domain,
        domain: @shop.https_domain,
        name: @shop.name,
        shopify_admin_url: @shop.shopify_admin_url,
        admin_locale: @shop.admin_locale || 'en',
        plugins: plugin_info,
        active_subscription:,
        is_base_charge_pending: Shops::BaseChargePolicy.new(@shop).pending?,
        is_custom_base_charge: subscription_manager.custom_base_charge?,
        base_charge: subscription_manager.base_charge,
        base_charge_threshold:,
        customers_count: @shop.customers_count,
        email: @shop.email,
        is_accounts_enabled: @shop.accounts_enabled?,
        is_development_shop: @shop.development_shop?,
        encoded_shopify_domain:,
        currency: @shop.currency,
        monthly_orders_count: @shop.monthly_orders_count,
        primary_locale: @shop.primary_locale,
      }
      info[:active_subscription_name] = subscription_manager.generate_name(ignore_base: true) if active_subscription
      info
    end

    private

    def encoded_shopify_domain
      crypt = ActiveSupport::MessageEncryptor.new(Rails.application.credentials.custom_forms_preview_secret)
      Base64.urlsafe_encode64(crypt.encrypt_and_sign(@shop.shopify_domain))
    end

    def plugin_info
      @shop.plugins.each_with_object({}) do |(plugin, value), info_hash|
        info_hash[plugin] = {
          value:,
          orders_count_exceeded: Shops::PluginOrderLimitExceededPolicy.new(@shop, plugin).exceeded?,
        }
      end.deep_merge(Shopify::Subscriptions::ManagerService::PLUGIN_INFO)
    end

    def base_charge_threshold
      if @shop.customers_count > Shopify::Subscriptions::ManagerService::MAX_CUSTOMERS_COUNT_LIMIT
        Shopify::Subscriptions::ManagerService::MAX_CUSTOMERS_COUNT_LIMIT
      else
        tier = Shopify::Subscriptions::ManagerService::BASE_CHARGE_TIERS.find do |tier|
          @shop.customers_count > tier[:threshold]
        end
        tier[:threshold] if tier
      end
    end
  end
end
