# frozen_string_literal: true

module Types
  module Admin
    class PaginatedLogsType < Types::BaseObject
      field :data, [Types::Admin::LogType], null: false
      field :meta, Types::Admin::PaginationMetaType, null: false
    end
  end
end
