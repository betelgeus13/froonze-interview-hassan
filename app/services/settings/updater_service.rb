# frozen_string_literal: true

module Settings
  class UpdaterService
    CUSTOMER_PAGE_SETTINGS = Set[
      'customer_page_navigation',
      'customer_page_enable_email_edit',
      'wishlist_social_share',
      'wishlist_enable_multilist',
      'customer_page_profile',
      'customer_page_cancel_order',
      'customer_page_phone_default_country',
      'customer_page_date_format',
      'customer_page_self_return_enabled',
      'customer_page_empty_panel_link',
    ].freeze

    SOCIAL_LOGINS_METAFIELD_SETTINGS = Set[
      'social_logins_providers',
      'social_logins_google_one_tap',
      'social_logins_forbid_registration',
    ].freeze

    WISHLIST_METAFIELD_SETTINGS = Set[
      'wishlist_tag_conditions',
      'wishlist_enable_multilist',
      'wishlist_enable_guest'
    ]

    CUSTOM_FORMS_SETTINGS = Set[
      'customer_page_phone_default_country'
    ]

    def initialize(shop)
      @shop = shop
    end

    def update(params)
      keys = params.keys + %i[id shop_id]
      ret = Settings::ValidatorService.new(shop: @shop).call(params:)

      return { error: ret[:error] } if ret[:error]

      @shop.setting.update!(params)
      {}
    end

    def self.run_callbacks(setting)
      changes = setting.previous_changes.keys.to_set
      if (changes & CUSTOMER_PAGE_SETTINGS).present?
        Settings::MetafieldUpdaterJob.perform_async(
          setting_id: setting.id,
          metafield_type: Settings::MetafieldUpdaterJob::CUSTOMER_PAGE
        )
      end
      if (changes & SOCIAL_LOGINS_METAFIELD_SETTINGS).present?
        Settings::MetafieldUpdaterJob.perform_async(
          setting_id: setting.id,
          metafield_type: Settings::MetafieldUpdaterJob::SOCIAL_LOGINS
        )
      end
      if (changes & WISHLIST_METAFIELD_SETTINGS).present?
        Settings::MetafieldUpdaterJob.perform_async(
          setting_id: setting.id,
          metafield_type: Settings::MetafieldUpdaterJob::WISHLIST
        )
      end

      Forms::MetafieldUpdaterJob.perform_async(setting.shop_id) if (changes & CUSTOM_FORMS_SETTINGS).present?

      {}
    end
  end
end
