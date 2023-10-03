class CreateShopifyThemes < ActiveRecord::Migration[6.1]
  def change
    create_table :shopify_themes do |t|
      # Shopify field
      t.string :name
      t.string :role
      t.bigint :theme_store_id
      t.bigint :external_id, null: false

      # internal fields
      t.json :settings, default: {}

      t.references :shop
      t.timestamps
    end
  end
end
