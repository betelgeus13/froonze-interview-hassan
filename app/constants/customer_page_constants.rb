# frozen_string_literal: true

module CustomerPageConstants
  NAVIGATION_TYPES = Set[
    PROFILE_NAV = 'profile',
    ORDERS_NAV = 'orders',
    ADDRESSES_NAV = 'addresses',
    RECENTLY_VIEWED_NAV = 'recently_viewed',
    WISHLIST_NAV = 'wishlist',
    PASSWORD_NAV = 'change_password',
    CUSTOM_PAGE_NAV = 'custom_page',
    INTEGRATION_NAV = 'integration',
    LOYALTY_NAV = 'loyalty',
  ].freeze

  REQUIRED_TYPES = Set[
    PROFILE_NAV,
    ORDERS_NAV,
    ADDRESSES_NAV,
    LOYALTY_NAV,
    RECENTLY_VIEWED_NAV,
    WISHLIST_NAV,
    PASSWORD_NAV,
  ].freeze

  CUSTOM_PAGES_LIMIT_PER_SHOP = 10

  CUSTOM_PAGE_TYPES = [
    CUSTOM_PAGE_SHOPIFY_TYPE = 'shopify',
    CUSTOM_PAGE_LINK_TYPE = 'link'
  ].freeze

  APP_PROXY = '/apps/customer-portal'
end
