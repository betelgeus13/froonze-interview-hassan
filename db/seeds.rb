# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Shop.create!(
  shopify_domain: 'sample-store.myshopify.com',
  shopify_token: 'xxx',
  access_scopes: 'write_products',
  email: 'sample@example.com',
  owner: 'john',
  name: 'doe',
  custom_domain: 'sample-store.com',
  shopify_plan: 'basic',
  primary_locale: 'en',
  country_code: 'VN',
  currency: 'VND',
  password_enabled: false,
  installed: true,
  shopify_customer_account_setting: 'optional'
)

Shop.first.shopify_themes.create!(ShopifyTheme::GLOBAL_CUSTOMIZATION_PARAMS)
Shop.first.shopify_themes.create!(
  name: 'Main',
  role: 'main',
  external_id: 12
)
