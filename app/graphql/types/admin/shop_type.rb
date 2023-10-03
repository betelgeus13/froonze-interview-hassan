# frozen_string_literal: true

module Types
  module Admin
    class ShopType < Types::BaseObject
      field :id, ID, null: false
      field :shopify_domain, String, null: false
      field :custom_domain, String, null: false
      field :email, String, null: false
      field :phone, String, null: true
      field :owner, String, null: false
      field :shopify_plan, String, null: false
      field :primary_locale, String, null: false
      field :country_code, String, null: false
      field :currency, String, null: false
      field :password_enabled, Boolean, null: false
      field :installed, Boolean, null: false
      field :beta_tester, Boolean, null: true
      field :shopify_customer_account_setting, String, null: true
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :last_visited_at, GraphQL::Types::ISO8601DateTime, null: true
      field :shopify_themes, [Types::Admin::ShopifyThemeType], null: false
      field :shopify_theme, Types::Admin::ShopifyThemeType, null: true do
        argument :theme_id, ID, required: true
      end
      field :active_shopify_subscription, Types::Admin::ShopifySubscriptionType, null: true
      field :customers_count, Integer, null: true
      field :is_development_shop, Boolean, null: false
      field :storefront_password, String, null: true

      def shopify_themes
        AssociationLoader.for(object.class, :shopify_themes).load(object).then do |shopify_themes|
          shopify_themes.sort_by { |theme| theme.global_customization? || theme.live? ? 0 : 1 }
        end
      end

      def shopify_theme(theme_id:)
        object.shopify_themes.find(theme_id)
      end

      def is_development_shop
        object.development_shop?
      end
    end
  end
end
