# frozen_string_literal: true

module Types
  module Admin
    class TeamMemberType < Types::BaseObject
      field :id, ID, null: false
      field :email, String, null: false
      field :name, String, null: false

      def name
        object.first_name + " " + object.last_name
      end
    end
  end
end
