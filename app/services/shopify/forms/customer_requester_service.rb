# frozen_string_literal: true

module Shopify
  module Forms
    class CustomerRequesterService
      class UpdateError < StandardError; end

      COMMON_CUSTOMER_QUERY = "
        id
        firstName
        lastName
        taxExempt
        defaultAddress {
          id
        }
        state
        addresses {
          id
          firstName,
          lastName,
          phone,
          country,
          address1,
          address2,
          city,
          company,
          province,
          zip,
        }
        metafields(first: 200) {
          edges {
            node {
              id
              key
              value
              namespace
            }
          }
        }
      "
      SHOPIFY_CUSTOMER_GET_BY_EXTERNAL_ID_QUERY = ShopifyAPI::GraphQL.client.parse <<-"QUERY"
        query($id: ID!) {
          customer(id: $id) {
            #{COMMON_CUSTOMER_QUERY}
          }
        }
      QUERY

      SHOPIFY_CUSTOMER_GET_BY_EMAIL_QUERY = ShopifyAPI::GraphQL.client.parse <<-"QUERY"
        query($query: String!) {
          customers(first: 1, query: $query){
            edges{
              node{
                #{COMMON_CUSTOMER_QUERY}
              }
            }
          }
        }
      QUERY

      SHOPIFY_CUSTOMER_UPDATE_QUERY = ShopifyAPI::GraphQL.client.parse <<-"GRAPHQL"
        mutation($input: CustomerInput!) {
          customerUpdate(input: $input) {
            userErrors {
              field
              message
            }
          }
        }
      GRAPHQL

      SHOPIFY_UPDATE_EMAIL_MARKETING_CONSENT_QUERY = ShopifyAPI::GraphQL.client.parse <<-"GRAPHQL"
        mutation($input: CustomerEmailMarketingConsentUpdateInput!) {
          customerEmailMarketingConsentUpdate(input: $input) {
            userErrors {
              field
              message
            }
          }
        }
      GRAPHQL

      def self.get_customer_by_email(email)
        variables = { query: "email:=#{email}" }
        result = ShopifyAPI::GraphQL.client.query(SHOPIFY_CUSTOMER_GET_BY_EMAIL_QUERY, variables:).to_h
        customer_edges = result.dig('data', 'customers', 'edges')
        return if customer_edges.blank?

        customer = customer_edges.first['node'].dup
        customer['metafields'] = customer['metafields']['edges'].map { |edge| edge['node'].dup }
        customer
      end

      def self.get_customer_by_external_id(external_id)
        return nil if external_id.blank?

        variables = { id: "gid://shopify/Customer/#{external_id}" }
        result = ShopifyAPI::GraphQL.client.query(SHOPIFY_CUSTOMER_GET_BY_EXTERNAL_ID_QUERY, variables:).to_h
        customer = result.dig('data', 'customer').dup
        customer['metafields'] = customer['metafields']['edges'].map { |edge| edge['node'].dup }
        customer
      end

      def self.update_customer(params, shop_id)
        params.delete('state')
        response = ShopifyAPI::GraphQL.client.query(SHOPIFY_CUSTOMER_UPDATE_QUERY, variables: { input: params })
        user_errors = response&.data&.customer_update&.user_errors
        error = if user_errors.present?
                  user_errors.first.message
                elsif response.errors.present?
                  Utils::RollbarService.error(UpdateError.new, shop_id:, errors: response.errors)
                  'Error with form submission. Please try again later.'
                end
        { error: }
      end

      # We need to check periodically. Maybe Shopify will allow to include this update in the customer update mutation
      def self.update_customer_email_consent(customer_id, accepts, shop_id)
        input = {
          customerId: customer_id,
          emailMarketingConsent: {
            marketingState: accepts ? 'SUBSCRIBED' : 'UNSUBSCRIBED',
            marketingOptInLevel: 'SINGLE_OPT_IN'
          }
        }
        response = ShopifyAPI::GraphQL.client.query(SHOPIFY_UPDATE_EMAIL_MARKETING_CONSENT_QUERY, variables: { input: })
        user_errors = response&.data&.customer_email_marketing_consent_update&.user_errors
        error = if user_errors.present?
                  user_errors.first.message
                elsif response.errors.present?
                  Utils::RollbarService.error(UpdateError.new, shop_id:, errors: response.errors)
                  'Error with form submission. Please try again later.'
                end
        { error: }
      end
    end
  end
end
