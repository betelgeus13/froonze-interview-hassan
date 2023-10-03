module Shopify
  module Subscriptions
    class ActivatorService
      class ShopifySubscriptionNotActiveError < StandardError; end

      def call(shop:, external_id:)
        return { error: 'Something went wrong. Please try again or contact support' } if external_id.blank?

        local_subscription = shop.shopify_subscriptions.find_by(external_id:)
        return { error: 'Could not find subscription' } if local_subscription.blank?
        return { notice: 'Successfully updated subscription' } if local_subscription.active?

        result = Shopify::Subscriptions::FetcherService.new(shop, external_id).call
        return { error: result[:error] } if result[:error]

        remote_subscription = result[:remote_subscription]

        if remote_subscription.status != 'ACTIVE'
          Utils::RollbarService.error(ShopifySubscriptionNotActiveError.new, shop_id: shop.id, external_id:)
          return { error: 'Something went wrong. Please try again or contact support' }
        end

        local_subscription.with_lock do
          # local_subscription is reloaded when lock is hit and all other concurent processes have to wait for lock to be lifted
          return { notice: 'Successfully updated subscription' } if local_subscription.active?

          ActiveRecord::Base.transaction do
            # One shop should only have one active subscription. However, that validation is performed only on the model level.
            # So, theoretically, it is still possible to have multiple active subscriptions per shop due to some race condition bug.
            shop.shopify_subscriptions.active.where.not(id: local_subscription.id).each(&:cancel!)
            local_subscription.activate!
          end
        end

        { notice: 'Successfully updated subscription' }
      end
    end
  end
end
