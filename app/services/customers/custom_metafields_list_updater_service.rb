# frozen_string_literal: true

module Customers
  class CustomMetafieldsListUpdaterService
    SINGLE_LINE_TEXT_METAFIELD_TYPE = 'single_line_text_field'
    DATE_METAFIELD_TYPE = 'date'
    INTEGER_METAFIELD_TYPE = 'number_integer'

    SHOPFIY_FIELD_TYPES = FormField::SHOPIFY_NATIVE_TYPES - Set[FormField::GENDER_TYPE, FormField::DATE_OF_BIRTH_TYPE]

    def initialize(shop:, field_params:, split_date_of_birth:, metafields_list: [])
      @shop = shop
      @metafields_list = metafields_list
      @custom_field_params = field_params.reject { |field_key, _| field_key.in?(SHOPFIY_FIELD_TYPES) }
      @split_date_of_birth = split_date_of_birth
    end

    def call
      @custom_field_params.each do |field_key, value|
        if field_key == 'date_of_birth'
          update_dob(value)
        elsif field_key == 'gender'
          create_or_update_or_delete_metafield(SINGLE_LINE_TEXT_METAFIELD_TYPE, 'gender', value)
        else
          custom_field = custom_fields_mapping[field_key]
          next if custom_field.blank?

          metafield_type = custom_field.metafield_type
          value = serialize_value(field_key, value)
          create_or_update_or_delete_metafield(metafield_type, field_key, value, custom_field.namespace)
        end
      end

      { metafields: @metafields_list }
    end

    private

    def custom_fields_mapping
      @custom_fields_mapping ||= @shop.custom_fields.where(key: @custom_field_params.keys).index_by(&:key)
    end

    def serialize_value(field_key, value)
      custom_field = custom_fields_mapping[field_key]
      return value if custom_field.blank?

      value = value.present? if custom_field.boolean_field_type? # to convert nil to false
      value = value.to_json if custom_field.metafield_type.starts_with?('list') || custom_field.boolean_field_type?
      value = value.to_s if custom_field.number?
      value
    end

    def create_or_update_or_delete_metafield(type, key, value, namespace = CustomField::SHOPIFY_METAFIELD_NAMESPACE)
      existing_metafield = @metafields_list.find { |metafield| metafield['key'] == key && metafield['namespace'] == namespace }
      if value.blank?
        return if existing_metafield.blank?

        Shopify::Metafields::DeleterService.call(existing_metafield['id'])
        @metafields_list.delete(existing_metafield)
      elsif existing_metafield.present?
        existing_metafield['value'] = value
      else
        @metafields_list << metafield_object(type, key, value, namespace)
      end
    end

    def update_dob(dob)
      dob = dob.to_date if dob.present? && !dob.is_a?(Date)
      dob = nil if dob == ''
      create_or_update_or_delete_metafield(DATE_METAFIELD_TYPE, 'date_of_birth', dob)
      return unless @split_date_of_birth

      create_or_update_or_delete_metafield(INTEGER_METAFIELD_TYPE, 'year_of_birth', dob&.year&.to_s)
      create_or_update_or_delete_metafield(INTEGER_METAFIELD_TYPE, 'month_of_birth', dob&.month&.to_s)
      create_or_update_or_delete_metafield(INTEGER_METAFIELD_TYPE, 'day_of_birth', dob&.day&.to_s)
    end

    def metafield_object(type, key, value, namespace)
      {
        'namespace' => namespace,
        'type' => type,
        'key' => key,
        'value' => value
      }
    end
  end
end
