# frozen_string_literal: true

module Customers
  class CustomerParamsService
    def call(shopify_customer:)
      customer_params = shopify_customer.attributes.slice(*Customers::FactoryService::FIELDS)
      customer_params[:email_marketing_consent] = customer_params[:email_marketing_consent]&.attributes.to_h
      customer_params[:sms_marketing_consent] = customer_params[:sms_marketing_consent]&.attributes.to_h
      customer_params[:id] = shopify_customer.id

      { customer_params: customer_params }
    end
  end
end
