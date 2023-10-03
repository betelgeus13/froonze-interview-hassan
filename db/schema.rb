# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_10_03_080641) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "shopify_subscriptions", force: :cascade do |t|
    t.bigint "shop_id", null: false
    t.string "external_id", null: false
    t.datetime "cancelled_at"
    t.datetime "activated_at"
    t.jsonb "plugins", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["external_id"], name: "index_shopify_subscriptions_on_external_id", unique: true
    t.index ["shop_id"], name: "index_shopify_subscriptions_on_shop_id"
  end

  create_table "shopify_theme_customizations", force: :cascade do |t|
    t.bigint "shopify_theme_id", null: false
    t.string "customization_type", null: false
    t.string "html"
    t.string "css"
    t.string "js"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shopify_theme_id", "customization_type"], name: "index_shopify_theme_customizations_on_theme_id_and_type", unique: true
  end

  create_table "shopify_themes", force: :cascade do |t|
    t.string "name"
    t.string "role"
    t.bigint "theme_store_id"
    t.bigint "external_id", null: false
    t.json "settings", default: {}
    t.bigint "shop_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shop_id"], name: "index_shopify_themes_on_shop_id"
  end

  create_table "shops", force: :cascade do |t|
    t.string "shopify_domain", null: false
    t.string "shopify_token", null: false
    t.string "access_scopes", null: false
    t.string "email"
    t.string "owner"
    t.string "name"
    t.string "custom_domain"
    t.string "shopify_plan"
    t.string "primary_locale"
    t.string "country_code"
    t.string "currency"
    t.boolean "password_enabled"
    t.boolean "installed"
    t.integer "custom_base_charge_in_cents"
    t.boolean "beta_tester"
    t.string "shopify_customer_account_setting"
    t.datetime "last_visited_at"
    t.integer "products_count", default: 0
    t.string "optional_webhooks", array: true
    t.boolean "accepts_marketing", default: true, null: false
    t.integer "customers_count"
    t.string "app_proxy"
    t.string "app_installation_id"
    t.string "phone"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "storefront_password"
    t.index ["shopify_domain"], name: "index_shops_on_shopify_domain", unique: true
  end

  create_table "team_members", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_team_members_on_email", unique: true
  end

  add_foreign_key "shopify_subscriptions", "shops"
  add_foreign_key "shopify_theme_customizations", "shopify_themes"
end
