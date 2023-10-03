module SettingConstants
  HASH_DEFAULTS = {
    'wishlist_social_share' => {
      'enabled' => false,
      'facebook' => true,
      'twitter' => true,
      'whatsapp' => true
    },
    'customer_page_profile' => {
      'spent' => true,
      'orders_count' => true,
      'addresses_count' => true,
      'gender' => true,
      'date_of_birth' => true
    },
    'customer_page_cancel_order' => {
      'customer_include_tags' => [],
      'customer_exclude_tags' => [],
      'order_include_tags' => [],
      'order_exclude_tags' => [],
      'button_color' => '#D34D4D',
      'button_text_color' => '#ffffff'
    },
    'wishlist_tag_conditions' => {
      'customer_include_tags' => [],
      'customer_exclude_tags' => [],
      'product_include_tags' => [],
      'product_exclude_tags' => []
    },
    'loyalty_email_notifications' => {
      'background_color' => '#fff',
      'text_color' => '#000',
      'button_background_color' => '#9E61FE',
      'button_text_color' => '#fff'
    }
  }

  ARRAY_DEFAULTS = {
    'customer_page_navigation' => Settings::CustomerPage::NavigationFetcherService::DEFAULT
  }

  WISHLIST_REMINDER_DISABLED = 'disabled'
  ENABLED_WISHLIST_REMINDER_STATUSES = [
    WISHLIST_REMINDER_RELATIVE = 'relative',
    WISHLIST_REMINDER_FIXED = 'fixed_day'
  ]

  WISHLIST_REMINDER_ALL_STATUSES = ENABLED_WISHLIST_REMINDER_STATUSES + [WISHLIST_REMINDER_DISABLED]
end
