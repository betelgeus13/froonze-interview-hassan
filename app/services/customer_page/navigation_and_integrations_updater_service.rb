module CustomerPage
  class NavigationAndIntegrationsUpdaterService

    def initialize(shop:, nav_items:, integration_inputs:)
      @shop = shop
      @nav_items = nav_items
      @integration_inputs = integration_inputs
      @error = nil
    end

    def call
      validate_data
      return { error: @error } if @error

      ActiveRecord::Base.transaction do
        update
        raise ActiveRecord::Rollback if @error.present?
      end
      return { error: @error } if @error

      # This job scheduling needs to happen only after the end of the db transaction. Otherwise, the job may retrieve old data
      Shopify::Metafields::IntegrationsUpdaterJob.perform_async(@shop.id, Integration::CUSTOMER_PAGE_TYPE) if @shop.cp_integrations_active?
      {}
    end

    private

    def validate_data
      validator = Settings::CustomerPage::NavigationValidatorService.new(@shop, @nav_items, @integration_inputs)
      return @error = 'Invalid data' unless validator.valid?
    end

    def update
      update_integrations if @shop.cp_integrations_active?

      return { error: @error } if @error

      @nav_items.each do |nav_item|
        process_nav_item(nav_item)
      end
      Settings::UpdaterService.new(@shop).update(customer_page_navigation: @nav_items)
    end

    def update_integrations
      @integration_inputs.each do |integration_input|
        integration = integration_hash[integration_input.key] || @shop.integrations.customer_page.new(key: integration_input.key)

        ret = Integrations::UpdaterService.new.call(shop: @shop, integration_input: integration_input.to_h, integration: integration)
        return @error = ret[:error] if ret[:error]

        integration_hash[integration_input.key] = integration
      end
    end

    def integration_hash
      @integration_hash ||= @shop.integrations.customer_page.index_by(&:key)
    end

    def process_nav_item(nav_item)
      if nav_item['type'] == CustomerPageConstants::CUSTOM_PAGE_NAV
        nav_item['page_id'] ||= SecureRandom.hex(8)
      elsif nav_item['type'] == CustomerPageConstants::INTEGRATION_NAV && @shop.cp_integrations_active?
        nav_item['settings'] = integration_hash[nav_item['integration_key']].settings
      end
    end

  end
end
