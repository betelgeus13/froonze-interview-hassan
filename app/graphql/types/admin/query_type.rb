module Types
  module Admin
    class QueryType < Types::BaseObject
      # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
      include GraphQL::Types::Relay::HasNodeField
      include GraphQL::Types::Relay::HasNodesField

      field :shop_search, [Types::Admin::ShopType], null: false do
        argument :query, String, required: true
      end

      def shop_search(query:)
        query = "%#{query.to_s.strip}%"
        Shop.where('shopify_domain ILIKE ? OR custom_domain ILIKE ?', query, query).limit(10)
      end

      field :shop, Types::Admin::ShopType, null: false do
        argument :id, ID, required: true
      end

      def shop(id:)
        Shop.find(id)
      end

    end
  end
end
