# frozen_string_literal: true

module Validators
  class CustomerField
    FIELD_METHOD = {
      phone: :phone_validator,
      gender: :gender_validator,
      date_of_birth: :date_of_birth_validator
    }

    def call(params:)
      params.each do |field, value|
        next if FIELD_METHOD[field].blank?

        ret = send(FIELD_METHOD[field], value: value)
        return ret if ret[:error]

        params[field] = ret[:result]
      end

      { result: params }
    end

    private

    def phone_validator(value:)
      { result: value.presence&.strip }
    end

    def gender_validator(value:)
      return { result: value.presence } if value.blank?
      return { result: nil } if value == 'null'
      return { error: 'Gender value is not accepted. Please select a valid option.' } unless Customer::GENDER_OPTIONS.include?(value)

      { result: value.strip }
    end

    def date_of_birth_validator(value:)
      return { result: value.presence } if value.blank?

      { result: Date.parse(value) }
    rescue StandardError
      { error: 'Date of Birth is not valid.' }
    end
  end
end
