class AdminSchema < GraphQL::Schema
  disable_introspection_entry_points if Rails.env.production?
  query(Types::Admin::QueryType)
  mutation(Types::Admin::MutationType)

  use GraphQL::Batch
end

AdminSchema.graphql_definition
