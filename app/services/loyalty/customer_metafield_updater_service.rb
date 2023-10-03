# frozen_string_literal: true
module Loyalty
  class CustomerMetafieldUpdaterService

    METAFIELD_NAMESPACE = '$app:froonze_cp'
    METAFIELD_KEY = 'loyalty_data'
    METAFIELD_TYPE = 'json'

    DISCOUNT_FIELDS = %w(
      value
      code
      min_order_subtotal
      discount_combines_with_free_shipping
      free_shipping_max_price
      free_shipping_combines_with_product_and_order_discounts
      ends_at
    ).freeze

    EVENT_FIELDS = %w(
      id
      event_type
      points
      admin_adjustment_customer_note
      created_at
    ).freeze

    ORDER_FIELDS = %w(
      external_id
      name
      token
    ).freeze

    SHOW_OLD_DISCOUNTS_PERIOND = 2.weeks

    def initialize(customer)
      @customer = customer
      @shop = customer.shop
    end

    def call
      metafield = {
        namespace: METAFIELD_NAMESPACE,
        key: METAFIELD_KEY,
        type: METAFIELD_TYPE,
        value: value,
        ownerId: "gid://shopify/Customer/#{@customer.external_id}"
      }
      result = @shop.with_shopify_session do
        Shopify::Metafields::GqlPublisherService.publish(metafields: [metafield])
      end
      return { error: result[:error] } if result[:error]

      {}
    end

    private

    def value
      {
        excluded: @customer.excluded_from_loyalty?,
        points: @customer.loyalty_points,
        discounts:,
        events:,
      }.to_json
    end

    def discounts
      discounts_list = @customer.loyalty_discounts
        .not_used_or_used_within(SHOW_OLD_DISCOUNTS_PERIOND)
        .not_expired_or_expired_within(SHOW_OLD_DISCOUNTS_PERIOND)
      # put used and expired discounts at the end
      discounts_list = discounts_list.sort_by do |discount|
        discount.used? || discount.expired? ? 1 : 0
      end
      discounts_list.map do |discount|
        serialized_disount = discount.attributes.slice(*DISCOUNT_FIELDS)
        serialized_disount[:collection_ids] = discount.clean_collection_ids
        if discount.used?
          serialized_disount[:is_used] = true
          serialized_disount[:order] = serialize_order(discount.order)
        end
        serialized_disount[:type] = discount.discount_type
        format_object(serialized_disount)
      end
    end

    def events
      @customer.loyalty_events.includes(:order, :loyalty_discount, :loyalty_spending_rule).reverse_order.map do |event|
        serialized_event = {}
        EVENT_FIELDS.each do |field|
          key = field.camelcase(:lower)
          serialized_event[key] = event.attributes[field]
        end
        serialized_event[:type] = event.event_type
        serialized_event[:order] = serialize_order(event.order) if event.order?
        if event.spend_points?
          serialized_event[:spending_rule] =  {
            title: event.loyalty_spending_rule.title
          }
          discount = event.loyalty_discount
          serialized_discount = {
            ends_at: discount.ends_at,
            is_used: discount.used?
          }
          serialized_discount[:order] = serialize_order(discount.order) if discount.used?
          serialized_event[:discount] = serialized_discount
        end
        format_object(serialized_event)
      end
    end

    def serialize_order(order)
      order.attributes.slice(*ORDER_FIELDS)
    end

    def format_object(hash)
      hash.each do |key, value|
        if value.is_a?(ActiveSupport::TimeWithZone)
          value = value.to_date.to_s
          hash[key] = value
        end
      end
      camelize_keys(hash)
    end

    def camelize_keys(hash)
      hash.each_with_object({}) do |(key, value), new_hash|
        value = camelize_keys(value) if value.is_a?(Hash)
        new_key = key.to_s.camelcase(:lower)
        new_hash[new_key] = value
        new_hash
      end
    end

  end
end
