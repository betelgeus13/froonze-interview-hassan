module Settings
  module CustomerPage
    class NavigationValidatorService
      def initialize(shop, nav_items, integrations)
        @shop = shop
        @nav_items = nav_items
        @integrations = integrations
      end

      def valid?
        return false unless all_required_types_are_present?
        return false unless types_are_valid?
        return false unless custom_pages_are_valid?
        return false if custom_pages_limit_is_exceeded?
        return false unless only_one_default_tab?
        return false unless default_page_is_valid?
        return false if @shop.cp_integrations_active? && !integrations_and_nav_items_are_consistent?

        true
      end

      private

      def all_required_types_are_present?
        types = @nav_items.map { |nav_item| nav_item['type'] }
        (CustomerPageConstants::REQUIRED_TYPES - types.to_set).blank?
      end

      def types_are_valid?
        @nav_items.each do |nav_item|
          return false unless CustomerPageConstants::NAVIGATION_TYPES.include?(nav_item['type'])
        end
        true
      end

      def custom_pages_are_valid?
        custom_pages.all? do |page|
          Settings::CustomerPage::CustomPageValidatorService.new(page).valid?
        end
      end

      def custom_pages_limit_is_exceeded?
        custom_pages.count > CustomerPageConstants::CUSTOM_PAGES_LIMIT_PER_SHOP
      end

      def custom_pages
        @custom_pages ||= @nav_items.select { |nav_item| nav_item['type'] == CustomerPageConstants::CUSTOM_PAGE_NAV }
      end

      def only_one_default_tab?
        default_count = @nav_items.count { |nav_item| nav_item['default'] }
        default_count <= 1
      end

      def default_page_is_valid?
        default_page = @nav_items.find { |nav_item| nav_item['default'] }
        return true if default_page.blank?

        type = default_page['type']
        return false if type == CustomerPageConstants::CUSTOM_PAGE_NAV && default_page['page_type'] == CustomerPageConstants::CUSTOM_PAGE_LINK_TYPE

        true
      end

      def integrations_and_nav_items_are_consistent?
        integration_nav_items = @nav_items.select { |nav_item| nav_item['type'] == CustomerPageConstants::INTEGRATION_NAV }
        integration_keys_in_nav_items = integration_nav_items.map { |nav_item| nav_item['integration_key'] }
        integration_keys = @integrations.map do |integration|
          next unless integration.enabled

          integration_info = IntegrationConstants::CUSTOMER_PAGE_INTEGRATIONS[integration.key]
          integration_info[:is_nav_item] ? integration.key : nil
        end.compact
        integration_keys_in_nav_items.sort == integration_keys.sort
      end
    end
  end
end
