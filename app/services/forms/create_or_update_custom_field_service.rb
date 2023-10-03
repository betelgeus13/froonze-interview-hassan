module Forms
  class CreateOrUpdateCustomFieldService
    def initialize(shop:, label:, id: nil, key: nil, type: nil, data_type: nil, namespace: nil)
      @shop = shop
      @id = id
      @label = label
      @key = key
      @type = type
      @data_type = data_type
      @namespace = normalize_namespace(namespace:)
    end

    def call
      return { error: 'Key must not be blank' } if @id.blank? && @key.blank?
      return { error: 'Key is already taken' } if @shop.custom_fields.where(key: @key).exists?

      if @type == CustomField::FILE_UPLOAD && @shop.plugins['custom_forms'] == 'basic'
        return { error: 'Please upgrade to Custom forms to Advanced plan to create File upload fields' }
      end

      custom_field = nil
      result = {}
      ActiveRecord::Base.transaction do
        custom_field = create_or_update_custom_field
        return { error: custom_field.errors.first.full_message } if custom_field.errors.present?

        result = CustomFields::MetafieldDefinitionUpdaterService.new(custom_field).call
        raise ActiveRecord::Rollback if result[:error]
      end
      return result if result[:error] || result[:notification]

      { custom_field: }
    end

    private

    def create_or_update_custom_field
      custom_field = @shop.custom_fields.find_by(id: @id)
      if custom_field.present?
        custom_field.update(label: @label)
      else
        custom_field = @shop.custom_fields.create(key: @key, field_type: @type, data_type: @data_type, label: @label, namespace: @namespace)
      end
      custom_field
    end

    def normalize_namespace(namespace:)
      return nil if namespace.blank? || namespace == CustomField::SHOPIFY_METAFIELD_NAMESPACE

      namespace
    end
  end
end
