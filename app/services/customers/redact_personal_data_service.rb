# frozen_string_literal: true

module Customers
  class RedactPersonalDataService
    REDACTED_EMAIL = 'anonymous'

    def call(customer:)
      customer.update(
        email: "#{REDACTED_EMAIL}-#{customer.id}@example.com",
        first_name: 'Anonymous',
        last_name: 'Customer',
        locale: '***'
      )

      customer.orders.update_all(
        data: {},
        customer_locale: '***',
        cart_token: '***',
        name: '***',
        token: '***',
        currency: '***',
        total_price: 0,
        subtotal_price: 0,
        updated_at: Time.current
      )
    end
  end
end
