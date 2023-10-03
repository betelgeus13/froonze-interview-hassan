# frozen_string_literal: true
module Settings
  module CustomerPage
    class NavigationFetcherService

      DEFAULT = [
        {
          'type' => CustomerPageConstants::PROFILE_NAV,
          'default' => true,
        },
        { 'type' => CustomerPageConstants::ORDERS_NAV },
        { 'type' => CustomerPageConstants::ADDRESSES_NAV},
        { 'type' => CustomerPageConstants::LOYALTY_NAV },
        { 'type' => CustomerPageConstants::RECENTLY_VIEWED_NAV },
        { 'type' => CustomerPageConstants::WISHLIST_NAV },
        { 'type' => CustomerPageConstants::PASSWORD_NAV },
      ].freeze

      def initialize(setting)
        @nav_items = setting.customer_page_navigation
        @shop = setting.shop
      end

      def call
        if @nav_items.blank?
          DEFAULT.dup
        else
          add_missing_items
          @nav_items
        end
      end

      private

      # this is just-in-case method. In case somehow wrong data was saved. This should not really happen
      def add_missing_items
        types = @nav_items.map { |nav_item| nav_item['type'] }
        missing_types = CustomerPageConstants::REQUIRED_TYPES - types.to_set
        missing_types.each do |type|
          @nav_items << { 'type' => type }
        end
      end

    end
  end
end
