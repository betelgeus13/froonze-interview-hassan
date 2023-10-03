# frozen_string_literal: true

module Forms
  class ApproveCustomerService
    class ApproveCustomerError < StandardError; end

    SHOPIFY_FIELDS = FormField::SHOPIFY_NATIVE_TYPES.to_a
    def call(shop:, params:, subject:, message:)
      params.stringify_keys!

      typecast_fields(params:, shop:)

      split_date_of_birth = Setting.select(:split_date_of_birth).find_by(shop_id: shop.id).split_date_of_birth
      service = Customers::CreateRemoteCustomerService.new(shop:, split_date_of_birth:, send_invite: true)

      shop.with_shopify_session do
        ret = service.call(params:, subject:, message:)
        return ret if ret[:error]
      end

      shop.awaiting_approval_customers.where(email: params['email']).destroy_all

      {}
    end

    private

    def typecast_fields(params:, shop:)
      custom_field_keys = params.keys - SHOPIFY_FIELDS
      custom_fields = shop.custom_fields.where(key: custom_field_keys)

      params['accepts_email_marketing'] = params['accepts_email_marketing'].to_s == 'true' if params.has_key?('accepts_email_marketing')
      params['tax_exempt'] = params['tax_exempt'].to_s == 'true'

      custom_fields.find_each do |custom_field|
        next if params[custom_field.key].nil?

        case custom_field.field_type
        when 'boolean'
          params[custom_field.key] = params[custom_field.key].to_s == 'true'
        when 'number_integer'
          params[custom_field.key] = params[custom_field.key].to_i
        when 'number_decimal'
          params[custom_field.key] = params[custom_field.key].to_f
        when 'multi_choice'
          case custom_field.data_type
          when 'number_integer'
            params[custom_field.key] = params[custom_field.key].map(&:to_i)
          when 'number_decimal'
            params[custom_field.key] = params[custom_field.key].map(&:to_f)
          end
        end
      end
    end
  end
end
