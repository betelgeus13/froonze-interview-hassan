module Shopify
  module Subscriptions
    class CancellerService

      class CancelError < StandardError; end;

      QUERY = ShopifyAPI::GraphQL.client.parse <<-'GRAPHQL'
        mutation ($id: ID!) {
          appSubscriptionCancel(id: $id) {
            userErrors {
              field
              message
            }
            appSubscription {
              id
            }
          }
        }
      GRAPHQL

      def initialize(shop)
        @shop = shop
      end

      def call
        if @shop.active_shopify_subscription.blank?
          return { error: 'No active subscription found for this shop' }
        end

        @shop.with_shopify_session do
          ActiveRecord::Base.transaction do
            @shop.active_shopify_subscription.cancel!
            cancel_remote_subscription
          end
        end
      rescue => error
        Utils::RollbarService.error(error, shop_id: @shop.id)
        { error: 'Could not cancel Shopify subscription. Please try again or contact support.' }
      end

      private

      def cancel_remote_subscription
        subscription_gid = "gid://shopify/AppSubscription/#{@shop.active_shopify_subscription.external_id}"
        result = ShopifyAPI::GraphQL.client.query(QUERY, variables: { id: subscription_gid })
        errors = result.data.app_subscription_cancel.user_errors
        if errors.present?
          raise CancelError.new(errors: errors)
        else
          {}
        end
      end

    end
  end
end
