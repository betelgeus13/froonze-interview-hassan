# frozen_string_literal: true

module Customers
  class UpdateRemoteCustomerService
    REMOTE_CUSTOMER_PARAMS = %w[
      first_name
      last_name
      phone
      tax_exempt
    ].freeze

    def initialize(shop:, split_date_of_birth:, email_edit_enabled:)
      @shop = shop
      @split_date_of_birth = split_date_of_birth
      @email_edit_enabled = email_edit_enabled
    end

    def call(remote_customer:, params:)
      Customers::CustomMetafieldsListUpdaterService.new(
        shop: @shop,
        split_date_of_birth: @split_date_of_birth,
        field_params: params,
        metafields_list: remote_customer['metafields']
      ).call

      params.slice(*REMOTE_CUSTOMER_PARAMS).each do |field_key, value|
        camelcase_key = field_key.camelcase(:lower)
        remote_customer[camelcase_key] = value
      end
      remote_customer['email'] = params['email'] if params.key?('email') && @email_edit_enabled
      create_or_update_default_address(remote_customer:, params:)

      if params.key?('accepts_email_marketing')
        result = Shopify::Forms::CustomerRequesterService.update_customer_email_consent(
          remote_customer['id'],
          params['accepts_email_marketing'],
          @shop.id
        )
        return result if result[:error]
      end
      Shopify::Forms::CustomerRequesterService.update_customer(remote_customer, @shop.id)
    end

    def create_or_update_default_address(remote_customer:, params:)
      default_address_id = remote_customer.dig('defaultAddress', 'id')
      remote_customer.delete('defaultAddress')
      default_address = Forms::AddressHashBuilderService.call(params:)[:result]

      return if default_address.blank?

      default_address['id'] = default_address_id if default_address_id.present? # if id is empty, a new default address will is created

      remote_customer['addresses'] = remote_customer['addresses'].each_with_object([]) do |address, obj|
        obj << (address['id'] == default_address['id'] ? default_address : address)
      end

      remote_customer['addresses'] = [default_address] if remote_customer['addresses'].blank?
    end
  end
end
