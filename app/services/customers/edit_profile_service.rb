# frozen_string_literal: true

module Customers
  class EditProfileService
    SETTINGS_TO_LOAD = %i[
      customer_page_enable_email_edit
      split_date_of_birth
    ].freeze

    def initialize(shop:)
      @shop = shop
      @setting = Setting.select(SETTINGS_TO_LOAD).find_by(shop_id: shop.id)
    end

    def call(params:)
      ret = Validators::CustomerField.new.call(params:)
      return ret if ret[:error]

      params = ret[:result].stringify_keys!
      @shop.with_shopify_session do
        update(params)
      end
    end

    private

    def update(params)
      params['accepts_email_marketing'] = params['accepts_marketing'] if params.has_key?('accepts_marketing')
      ret = update_remote_customer(params)
      return ret if ret[:error]

      result = update_local_customer(params)
      return result if result[:error]

      { result: result[:customer] }
    end

    def update_remote_customer(params)
      remote_customer = Shopify::Forms::CustomerRequesterService.get_customer_by_external_id(params['external_id'])
      return { error: 'Could not find customer' } if remote_customer.blank?

      Customers::UpdateRemoteCustomerService.new(
        shop: @shop,
        split_date_of_birth: @setting.split_date_of_birth,
        email_edit_enabled: @setting.customer_page_enable_email_edit
      ).call(remote_customer:, params:)
    end

    def update_local_customer(params)
      params.deep_symbolize_keys!
      params[:id] = params[:external_id]
      Customers::FactoryService.new(
        shop: @shop,
        email_edit_enabled: @setting.customer_page_enable_email_edit
      ).create_or_update(params:)
    end
  end
end
