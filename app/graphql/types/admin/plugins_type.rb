module Types
  module Admin
    class PluginsType < Types::BaseObject
      graphql_name 'PluginsType'

      field :reorder_btn, Boolean, null: false
      field :custom_pages, Boolean, null: false
      field :recently_viewed, Boolean, null: false
      field :social_logins, String, null: true
      field :wishlist, String, null: true
      field :cp_integrations, String, null: true
      field :custom_forms, String, null: true
      field :loyalty, String, null: true
      field :order_actions, String, null: true
    end
  end
end
