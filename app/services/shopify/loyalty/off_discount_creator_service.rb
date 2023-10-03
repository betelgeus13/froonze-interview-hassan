# frozen_string_literal: true
module Shopify
  module Loyalty
    class OffDiscountCreatorService

      DISCOUNT_MUTATION = ShopifyAPI::GraphQL.client.parse <<-"GRAPHQL"
        mutation(
            $discount_value: DiscountCustomerGetsValueInput!,
            $code: String!,
            $customer_ids: [ID!],
            $starts_at: DateTime!,
            $ends_at: DateTime,
            $min_order_subtotal: Decimal,
            $applied_to_all_items: Boolean,
            $combines_with_free_shipping: Boolean,
            $collection_ids: [ID!]
        ) {
          discountCodeBasicCreate(basicCodeDiscount: {
            title: $code,
            appliesOncePerCustomer: true,
            customerSelection: {
              customers: {
                add: $customer_ids
              }
            }
            customerGets: {
              value: $discount_value,
              items: {
                all: $applied_to_all_items,
                collections: {
                  add: $collection_ids,
                }
              }
            }
            code: $code,
            startsAt: $starts_at,
            endsAt: $ends_at,
            usageLimit: 1,
            minimumRequirement: {
              subtotal: {
                greaterThanOrEqualToSubtotal: $min_order_subtotal,
              }
            },
            combinesWith: {
              shippingDiscounts: $combines_with_free_shipping
            }
          })
          {
            userErrors { field message code }
            codeDiscountNode {
              id
              codeDiscount {
                ... on DiscountCodeBasic {
                  status
                  title
                  summary
                  shortSummary
                  minimumRequirement
                  startsAt
                  endsAt
                  codes (first:1) {
                    edges {
                      node {
                        code
                      }
                    }
                  }
                }
              }
            }
          }
        }
      GRAPHQL

      DISCOUNT_ID_STATIC_PART = 'gid://shopify/DiscountCodeNode/'

      def initialize(shop)
        @shop = shop
      end

      def create_amount_discount(variables)
        variables = prepare_amount_variables(variables)
        send_request(variables)
      end

      def create_percentage_discount(variables)
        variables = prepare_percentage_variables(variables)
        send_request(variables)
      end

      private

      def send_request(variables)
        @shop.with_shopify_session do
          response = ShopifyAPI::GraphQL.client.query(DISCOUNT_MUTATION, variables: variables).to_h
          return { error: response['errors'][0]['message'] } if response['errors'].present?
          data = response.dig('data', 'discountCodeBasicCreate')
          errors = data['userErrors']
          return { error: errors[0]['message'] } if errors.present?
          discount = data['codeDiscountNode']
          return { error: 'Something went wrong' } if discount.blank?
          { discount_id: discount['id'].split(DISCOUNT_ID_STATIC_PART)[1] }
        end
      end

      def prepare_amount_variables(variables)
        variables = prepare_general_variables(variables)
        variables[:discount_value] = {
          discountAmount:  {
            amount: variables[:amount],
            appliesOnEachItem: false
          }
        }
        variables.delete(:amount)
        variables
      end

      def prepare_percentage_variables(variables)
        variables = prepare_general_variables(variables)
        variables[:discount_value] = {
          percentage: variables[:percentage]
        }
        variables.delete(:percentage)
        variables
      end

      def prepare_general_variables(variables)
        variables = default_variables.merge(variables)
        variables[:applied_to_all_items] = variables[:collection_ids].blank?
        variables
      end

      def default_variables
        {
          starts_at: Time.current.iso8601,
        }
      end

    end
  end
end
