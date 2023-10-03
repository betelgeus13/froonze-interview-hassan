module Loyalty
  class ShopSettingsMetafieldUpdaterService
    METAFIELD_NAMESPACE = 'loyalty'
    METAFIELD_KEY = 'settings'
    METAFIELD_TYPE = 'json'

    EARNING_RULE_FIELDS = %w[
      earning_type
      value
      order_earning_type
      order_increment_spending_unit
      advanced_options
    ].freeze

    SPENDING_RULE_FIELDS = %w[
      id
      title
      reward_type
      points_cost
      discount_amount_points_type
      discount_value
      discount_apply_to
      discount_collection_ids
      discount_expiration_enabled
      discount_expires_after_days
      discount_min_order_subtotal
      discount_min_order_requirement_enabled
      discount_combines_with_free_shipping
      free_shipping_max_price_enabled
      free_shipping_max_price
      free_shipping_combines_with_product_and_order_discounts
    ].freeze

    def initialize(shop)
      @shop = shop
    end

    def call
      Shopify::SetShopAppInstallationIdService.new.call(shop: @shop) if @shop.app_installation_id.blank?
      metafield = {
        namespace: METAFIELD_NAMESPACE,
        key: METAFIELD_KEY,
        type: METAFIELD_TYPE,
        value:,
        ownerId: @shop.app_installation_id
      }
      ret = @shop.with_shopify_session do
        Shopify::Metafields::GqlPublisherService.publish(metafields: [metafield])
      end

      raise ret[:error] if ret[:error]
    end

    private

    def value
      {
        earning_rules:,
        spending_rules:
      }.to_json
    end

    def earning_rules
      @shop.loyalty_earning_rules.active.map do |rule|
        rule.attributes.slice(*EARNING_RULE_FIELDS)
      end
    end

    def spending_rules
      @shop.loyalty_spending_rules.active.order(:position).map do |rule|
        rule.attributes.slice(*SPENDING_RULE_FIELDS)
      end
    end
  end
end
