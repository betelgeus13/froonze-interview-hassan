class CreateShopifySubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :shopify_subscriptions do |t|
      t.belongs_to :shop, null: false, foreign_key: true, index: false, index: true
      t.string :external_id, null: false, index: { unique: true }
      t.datetime :cancelled_at
      t.datetime :activated_at
      t.jsonb :plugins, default: {}, null: false

      t.timestamps
    end
  end
end
