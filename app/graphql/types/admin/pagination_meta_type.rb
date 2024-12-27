# frozen_string_literal: true

module Types
  module Admin
    class PaginationMetaType < Types::BaseObject
      field :current_page, Integer, null: false
      field :total_pages, Integer, null: false
    end
  end
end
