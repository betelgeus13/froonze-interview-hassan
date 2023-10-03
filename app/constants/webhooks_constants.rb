# frozen_string_literal: true

class WebhooksConstants
  CUSTOMER_FIELDS = %w[
    id
    tags
    email
    first_name
    last_name
    orders_count
    total_spent
    country
    country_code
    phone
    tags
    accepts_marketing
    email_marketing_consent
    sms_marketing_consent
    state
  ].freeze

  PRODUCT_FIELDS = %w[
    id
    variants
    handle
    title
    images
    status
    published_at
  ].freeze

  ORDER_FIELDS = %w[
    id
    cart_token
    currency
    customer
    customer_locale
    created_at
    cancelled_at
    discount_codes
    financial_status
    fulfillment_status
    line_items
    name
    refunds
    subtotal_price
    total_price
    token
    total_shipping_price_set
    total_tax
  ].freeze

  SHOP_FIELDS = %w[
    id
    plan_name
  ].freeze

  HOOKS_URL_PREFIX = "#{Rails.application.credentials.https_url}/webhooks/"

  REQUIRED_HOOKS = [
    {
      topic: 'customers/update',
      address: "#{HOOKS_URL_PREFIX}customers_update",
      format: 'json',
      fields: CUSTOMER_FIELDS
    },
    {
      topic: 'customers/create',
      address: "#{HOOKS_URL_PREFIX}customers_create",
      format: 'json',
      fields: CUSTOMER_FIELDS
    },
    {
      topic: 'customers/delete',
      address: "#{HOOKS_URL_PREFIX}customers_delete",
      format: 'json',
      fields: CUSTOMER_FIELDS
    },
    {
      topic: 'app/uninstalled',
      address: "#{HOOKS_URL_PREFIX}uninstalled",
      format: 'json'
    },
    {
      topic: 'themes/create',
      address: "#{HOOKS_URL_PREFIX}themes_create",
      format: 'json'
    },
    {
      topic: 'themes/update',
      address: "#{HOOKS_URL_PREFIX}themes_update",
      format: 'json'
    },
    {
      topic: 'themes/delete',
      address: "#{HOOKS_URL_PREFIX}themes_delete",
      format: 'json'
    },
    {
      topic: 'shop/update',
      address: "#{HOOKS_URL_PREFIX}shop_update",
      format: 'json',
      fields: SHOP_FIELDS

    }
  ].freeze

  OPTIONAL_HOOKS = {
    (ORDERS_CREATE = 'orders/create') => {
      address: "#{HOOKS_URL_PREFIX}orders_create",
      format: 'json',
      fields: ORDER_FIELDS
    },
    (ORDERS_UPDATED = 'orders/updated') => {
      address: "#{HOOKS_URL_PREFIX}orders_updated",
      format: 'json',
      fields: ORDER_FIELDS
    },
    (PRODUCTS_UPDATE = 'products/update') => {
      address: "#{HOOKS_URL_PREFIX}products_update",
      format: 'json',
      fields: PRODUCT_FIELDS
    },
    (PRODUCTS_CREATE = 'products/create') => {
      address: "#{HOOKS_URL_PREFIX}products_create",
      format: 'json',
      fields: PRODUCT_FIELDS
    },
    (PRODUCTS_DELETE = 'products/delete') => {
      address: "#{HOOKS_URL_PREFIX}products_delete",
      format: 'json',
      fields: PRODUCT_FIELDS
    }
  }.freeze

  OPTIONAL_WEBHOOK_TOPICS_FOR_PLUGINS = {
    ShopifySubscription::WISHLIST => [
      ORDERS_CREATE,
      PRODUCTS_UPDATE,
      PRODUCTS_CREATE,
      PRODUCTS_DELETE
    ],
    ShopifySubscription::LOYALTY => [
      ORDERS_CREATE,
      ORDERS_UPDATED,
    ]
  }.freeze

  OPTIONAL_WEBBOOK_TOPICS = OPTIONAL_HOOKS.keys.to_set.freeze
end
