# frozen_string_literal: true

module Forms
  class CreateAwaitingApprovalCustomerService
    class CreateAwaitingApprovalCustomerError < StandardError; end

    SETTINGS = %i[
      forms_notify_shop_of_create_awaiting_approval_customer
      forms_notify_customer_of_create_awaiting_approval_customer
    ]

    def initialize(shop:, form:)
      @shop = shop
      @form = form
    end

    def call(params:, locale:)
      ret = validate(params:)
      return ret if ret[:error]

      shopify_fields = params.select { |field_key, _| field_key in FormField::SHOPIFY_NATIVE_TYPES }
      custom_fields_params = params.reject { |field_key, _| field_key in FormField::SHOPIFY_NATIVE_TYPES }
      custom_fields_mapping = @shop.custom_fields.where(key: custom_fields_params.keys).index_by(&:key)

      awaiting_approval_customer = @shop.awaiting_approval_customers.new(
        form: @form,
        email: shopify_fields.delete('email'),
        first_name: shopify_fields.delete('first_name'),
        last_name: shopify_fields.delete('last_name'),
        shopify_fields:,
        locale:
      )

      ActiveRecord::Base.transaction do
        awaiting_approval_customer.save!

        custom_field_values_data = custom_fields_params.map do |field_key, value|
          next if custom_fields_mapping[field_key].blank?

          awaiting_approval_customer.custom_field_values.create(
            custom_field_id: custom_fields_mapping[field_key].id,
            value:
          )
        end
      end

      schedule_notifications(awaiting_approval_customer:)

      {}
    rescue StandardError => e
      Utils::RollbarService.error(CreateAwaitingApprovalCustomerError.new(e), shop_id: @shop.id)
      { error: 'Something went wrong. Please reload the page and try again. The development team has been informed.' }
    end

    private

    def validate(params:)
      return { error: 'Invalid phone number' } if params.has_key?('phone') && params['phone'].present? && !Phonelib.valid?(params['phone'])

      {}
    end

    def schedule_notifications(awaiting_approval_customer:)
      setting = Setting.select(SETTINGS).find_by(shop_id: @shop.id)

      if setting.forms_notify_shop_of_create_awaiting_approval_customer
        Forms::AwaitingApprovalCustomer::NotifyShopCreateJob.perform_async(awaiting_approval_customer_id: awaiting_approval_customer.id)
      end

      return unless setting.forms_notify_customer_of_create_awaiting_approval_customer

      Forms::AwaitingApprovalCustomer::NotifyCustomerCreateJob.perform_async(awaiting_approval_customer_id: awaiting_approval_customer.id)
    end
  end
end
