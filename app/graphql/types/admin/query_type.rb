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

      field :team_member_search, [Types::Admin::TeamMemberType], null: false do
        argument :query, String, required: true
      end

      def team_member_search(query:)
        query = "%#{query.to_s.strip}%"
        TeamMember.where('first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?', query, query, query).limit(10)
      end

      field :logs, Types::Admin::PaginatedLogsType, null: false do
        argument :member_id, ID, required: false
        argument :page, Integer, required: false, default_value: 1
        argument :per_page, Integer, required: false, default_value: 10
      end

      def logs(member_id: nil, page: 1, per_page: 10)
        scope = member_id ? Ahoy::Event.where(user_id: member_id) : Ahoy::Event.all
        pagy, records = pagy(scope, page: page, items: per_page)

        {
          data: records,
          meta: {
            current_page: pagy.page,
            total_pages: pagy.pages,
          }
        }
      rescue Pagy::OverflowError
        {
          data: [],
          meta: {
            current_page: page,
            total_pages: 0,
          }
        }
      end
    end
  end
end
