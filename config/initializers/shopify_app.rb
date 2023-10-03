# not needed for admin task

# ShopifyApp.configure do |config|
#   config.application_name = 'Concierge Customer Accounts'
#   config.old_secret = ''
#   # Consult this page for more scope options:
#   # https://help.shopify.com/en/api/getting-started/authentication/oauth/scopes
#   config.scope = 'read_customers,write_customers,read_themes,write_themes,read_locales,write_locales,read_translations,write_translations,read_content,read_products,read_orders,write_orders,read_discounts,write_discounts'
#   config.embedded_app = true
#   # inline means it is executed as a service after authentication and not as a job.
#   # we need the shops information to be loaded before we show any page on installation.
#   config.after_authenticate_job = { job: Shopify::AfterAuthenticateJob, inline: true }
#   config.api_version = '2023-01'
#   ShopifyAPI::Base.api_version = config.api_version # to set default version for ShopifyAPI::GraphQL.client - https://github.com/Shopify/shopify_api/blob/master/docs/graphql.md#api-versioning
#   config.shop_session_repository = 'Shop'

#   config.reauth_on_access_scope_changes = true

#   # need ot use cookie authentication with non embedded app. Otherwise the login page is stuck in eternal loop because of a bug in shopify_app gem
#   config.allow_jwt_authentication = true
#   config.allow_cookie_authentication = false

#   config.api_key = Rails.application.credentials.shopify[:key]
#   config.secret = Rails.application.credentials.shopify[:secret]

#   if defined? Rails::Server
#     raise('Missing SHOPIFY_API_KEY. See https://github.com/Shopify/shopify_app#requirements') unless config.api_key
#     raise('Missing SHOPIFY_API_SECRET. See https://github.com/Shopify/shopify_app#requirements') unless config.secret
#   end

#   config.webhook_jobs_namespace = 'shopify/webhooks'

#   config.webhooks = WebhooksConstants::REQUIRED_HOOKS
# end

# # ShopifyApp::Utils.fetch_known_api_versions                        # Uncomment to fetch known api versions from shopify servers on boot
# # ShopifyAPI::ApiVersion.version_lookup_mode = :raise_on_unknown    # Uncomment to raise an error if attempting to use an api version that was not previously known
