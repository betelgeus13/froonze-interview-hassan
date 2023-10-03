# frozen_string_literal: true
module Shopify
  module Loyalty
    class FreeShippingDiscountCreatorService

      DISCOUNT_MUTATION = ShopifyAPI::GraphQL.client.parse <<-"GRAPHQL"
        mutation (
            $code: String!,
            $customer_ids: [ID!],
            $maximum_shipping_price: Decimal,
            $combines_with_product_and_order_discounts: Boolean,
            $starts_at: DateTime!,
            $ends_at: DateTime
        ) {
          discountCodeFreeShippingCreate(freeShippingCodeDiscount: {
            title: $code,
            appliesOncePerCustomer: true,
            code: $code,
            combinesWith: {
              orderDiscounts: $combines_with_product_and_order_discounts,
              productDiscounts: $combines_with_product_and_order_discounts
            },
            customerSelection: {
              customers: {
                add: $customer_ids
              }
            },
            maximumShippingPrice: $maximum_shipping_price,
            startsAt: $starts_at,
            endsAt: $ends_at,
            usageLimit: 1
          }) {
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
            userErrors {
              field
              message
            }
          }
        }
      GRAPHQL

      DISCOUNT_ID_STATIS_PART = 'gid://shopify/DiscountCodeNode/'

      def initialize(shop)
        @shop = shop
      end

      def call(variables)
        variables = default_variables.merge(variables)
        @shop.with_shopify_session do
          response = ShopifyAPI::GraphQL.client.query(DISCOUNT_MUTATION, variables: variables).to_h
          return { error: response['errors'][0]['message'] } if response['errors'].present?
          data = response.dig('data', 'discountCodeFreeShippingCreate')
          errors = data['userErrors']
          return { error: errors[0]['message'] } if errors.present?
          discount = data['codeDiscountNode']
          return { error: 'Something went wrong' } if discount.blank?
          { discount_id: discount['id'].split(DISCOUNT_ID_STATIS_PART)[1] }
        end
      end

      private

      def default_variables
        {
          starts_at: Time.current.iso8601,
        }
      end

    end
  end
end
