# frozen_string_literal: true

module Customers
  class CreateRemoteCustomerService
    class CreateRemoteCustomerError < StandardError; end
    SHOPIFY_ERROR_FIELDS_TO_SHOW_TO_CUSTOMER = %w[phone addresses.country].freeze

    def initialize(shop:, split_date_of_birth:, send_invite:)
      @shop = shop
      @split_date_of_birth = split_date_of_birth
      @send_invite = send_invite
    end

    def call(params:, subject: nil, message: nil)
      metafields = Customers::CustomMetafieldsListUpdaterService.new(
        shop: @shop,
        split_date_of_birth: @split_date_of_birth,
        field_params: params
      ).call[:metafields]

      customer_params = {
        email: params['email'],
        first_name: params['first_name'],
        last_name: params['last_name'],
        phone: params['phone'],
        metafields:,
        send_email_welcome: true,
        addresses: [Forms::AddressHashBuilderService.call(params:)[:result]],
        tax_exempt: params['tax_exempt']
      }

      if params.key?('accepts_email_marketing')
        customer_params[:email_marketing_consent] = {
          state: params['accepts_email_marketing'] ? 'subscribed' : 'unsubscribed',
          opt_in_level: 'single_opt_in'
        }
      end

      unless @send_invite
        customer_params[:password] = params['password']
        customer_params[:password_confirmation] = params['password']
      end

      remote_customer = ShopifyAPI::Customer.create(customer_params)

      ret = check_remote_customer_errors(remote_customer:)
      return ret if ret[:error]

      if @send_invite
        customer_invite = ShopifyAPI::CustomerInvite.new(
          'subject' => subject,
          'custom_message' => message
        )
        remote_customer.send_invite(customer_invite)
      end

      {
        customer_external_id: remote_customer.id
      }
    rescue StandardError => e
      Utils::RollbarService.error(CreateRemoteCustomerError.new(e), shop_id: @shop.id)
      { error: e }
    end

    def check_remote_customer_errors(remote_customer:)
      return {} unless remote_customer.errors.present?

      SHOPIFY_ERROR_FIELDS_TO_SHOW_TO_CUSTOMER.each do |field|
        errors = remote_customer.errors.full_messages_for(field)
        return { error: errors.join('; '), all_errors: remote_customer.errors.full_messages } if errors.present?
      end
      Utils::RollbarService.error(CreateRemoteCustomerError.new, shop_id: @shop.id, errors: remote_customer.errors.full_messages)
      {
        error: 'Something went wrong. Please reload the page and try again. The development team has been informed.',
        all_errors: remote_customer.errors.full_messages
      }
    end
  end
end
