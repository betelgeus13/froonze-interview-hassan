# frozen_string_literal: true

module Forms
  class AddressHashBuilderService
    def self.call(params:)
      address_params = params.select { |field_key, _| field_key.starts_with?('address.') }
      result = address_params.each_with_object({}) do |(field_key, value), address|
        address_key = field_key.split('address.').second.camelcase(:lower)
        address[address_key] = value
        address
      end

      { result: }
    end
  end
end
