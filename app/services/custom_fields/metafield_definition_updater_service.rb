module CustomFields
  class MetafieldDefinitionUpdaterService

    def initialize(custom_field)
      @custom_field = custom_field
      @shop = custom_field.shop
    end

    def call
      params = {
        name: @custom_field.label,
        key: @custom_field.key,
        namespace: @custom_field.namespace,
        type: @custom_field.metafield_type,
      }
      result = Shopify::Forms::CreateOrUpdateMetafieldDefinitionService.new(@shop, params).call

      return result if result[:error] || result[:notification]
      {}
    end

  end
end
