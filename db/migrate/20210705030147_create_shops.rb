class CreateShops < ActiveRecord::Migration[6.1]
  def self.up
    create_table :shops do |t|
      t.string :shopify_domain, null: false
      t.string :shopify_token, null: false
      t.string :access_scopes, null: false

      # these fields are added after the shop is created so we cannot have an validation on them
      t.string :email
      t.string :owner
      t.string :name
      t.string :custom_domain
      t.string :shopify_plan
      t.string :primary_locale
      t.string :country_code
      t.string :currency
      t.boolean :password_enabled
      t.boolean :installed

      t.integer :custom_base_charge_in_cents
      t.boolean :beta_tester
      t.string :shopify_customer_account_setting
      t.datetime :last_visited_at
      t.integer :products_count, default: 0
      t.string :optional_webhooks, array: true
      t.boolean :accepts_marketing, default: true, null: false
      t.integer :customers_count
      t.string :app_proxy
      t.string :app_installation_id
      t.string :phone
      t.string :storefront_password

      t.timestamps
    end

    add_index :shops, :shopify_domain, unique: true
  end

  def self.down
    drop_table :shops
  end
end
