# This patch is to solve https://github.com/Shopify/shopify_app/issues/1257

module GemPatches
  module ShopifyApp
    module ShopAccessScopesVerification

      def current_shopify_domain
        current_shop&.shopify_domain
      end

    end
  end
end
