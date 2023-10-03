# frozen_string_literal: true

module Shopify
  module Subscriptions
    class CreatorService
      class CreateError < StandardError; end

      QUERY = ShopifyAPI::GraphQL.client.parse <<-'GRAPHQL'
        mutation ($lineItems: [AppSubscriptionLineItemInput!]!, $name: String!, $returnUrl: URL!, $test: Boolean, $trialDays: Int!) {
          appSubscriptionCreate(lineItems: $lineItems, name: $name, returnUrl: $returnUrl, test: $test, trialDays: $trialDays) {
            userErrors {
              field
              message
            }
            appSubscription {
              id
              test
            }
            confirmationUrl
          }
        }
      GRAPHQL

      TRIAL_DAYS = 14

      def initialize(shop, name, amount)
        @shop = shop
        @name = name
        @amount = amount
      end

      def call
        @shop.with_shopify_session do
          create_remote_subscription
        end
      end

      private

      def create_remote_subscription
        variables = generate_variables_hash
        result = ShopifyAPI::GraphQL.client.query(QUERY, variables:)
        errors = result.data.app_subscription_create.user_errors
        if errors.present?
          Utils::RollbarService.error(CreateError.new, shop_id: @shop.id, plan_name: @name, plan_amount: @amount, errors:)
          return { error: 'Could not create Shopify subscription' }
        end

        data = result.data.app_subscription_create
        {
          subscription: data.app_subscription,
          confirmation_url: data.confirmation_url
        }
      end

      def generate_variables_hash
        return_url = "#{@shop.shopify_url}#{Rails.application.routes.url_helpers.shopify_subscription_callback_path}?shop_id=#{@shop.id}"
        {
          lineItems: [
            {
              plan: {
                appRecurringPricingDetails: {
                  price: {
                    amount: @amount,
                    currencyCode: 'USD'
                  }
                }
              }
            }
          ],
          name: @name,
          returnUrl: return_url,
          test: test_subscription?,
          trialDays: calculate_trial_days
        }
      end

      def calculate_trial_days
        first_subscription = @shop.shopify_subscriptions.not_pending.first
        return TRIAL_DAYS if first_subscription.blank?

        days = TRIAL_DAYS - (Date.current - first_subscription.created_at.to_date).to_i
        [days, 0].max
      end

      def test_subscription?
        @shop.beta_tester? || @shop.development_shop?
      end
    end
  end
end
