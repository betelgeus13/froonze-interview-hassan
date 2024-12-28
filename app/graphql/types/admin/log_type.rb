# frozen_string_literal: true

module Types
  module Admin
    class LogType < Types::BaseObject
      field :id, ID, null: false
      field :time, GraphQL::Types::ISO8601DateTime, null: false
      field :name, String, null: false
      field :properties, String, null: false
      field :team_member, Types::Admin::TeamMemberType, null: false
    end
  end
end
