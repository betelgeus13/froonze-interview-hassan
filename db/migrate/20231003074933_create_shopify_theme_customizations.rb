class CreateShopifyThemeCustomizations < ActiveRecord::Migration[6.1]
  def change
    create_table :shopify_theme_customizations do |t|
      t.belongs_to :shopify_theme, foreign_key: true, null: false, index: false
      t.string :customization_type, null: false
      t.string :html
      t.string :css
      t.string :js

      t.timestamps
    end

    add_index :shopify_theme_customizations, %i[shopify_theme_id customization_type], unique: true,
                                                                                      name: :index_shopify_theme_customizations_on_theme_id_and_type
  end
end
