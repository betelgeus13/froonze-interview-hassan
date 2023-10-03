module Types
  module Admin
    class ShopifySubscriptionType < Types::BaseObject
      graphql_name 'ShopifySubscription'

      field :activated_at, GraphQL::Types::ISO8601DateTime, null: true
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :amount, String, null: false
      field :is_test, Boolean, null: false
      field :plugins, Types::Admin::PluginsType, null: false

      def amount
        "$#{(object.amount_in_cents / 100.0).round(2)}"
      end
    end
  end
end
