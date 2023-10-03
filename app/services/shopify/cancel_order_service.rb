# frozen_string_literal: true

module Shopify
  class CancelOrderService
    PAID_STATUS = 'paid'
    ACCEPTED_FULFILLED_STATUS = nil
    NOTE_REASON = 'Cancel Reason'

    def initialize(shop:)
      @shop = shop
    end

    def call(external_id:, customer_external_id:, reason:)
      setting = Setting.select(:customer_page_cancel_order_restock, :id).find_by(shop_id: @shop.id)
      customer_page_cancel_order_restock = setting.customer_page_cancel_order_restock

      @shop.with_shopify_session do
        order = ShopifyAPI::Order.find(external_id)

        if order.fulfillment_status != ACCEPTED_FULFILLED_STATUS
          return { error: 'We cannot cancel an order which is paid and has fulfilled line items. Please contact the store through the contact form.' }
        end

        if order.customer.id.to_s != customer_external_id.to_s
          return { error: 'Sorry you do not have access to this order.' }
          Utils::RollbarService.error(e, shop_id: @shop.id, order_external_id: external_id, customer_external_id:)
        end

        cancel_params = {
          reason: 'customer', # this field accepts only predifined values
          email: true
        }

        order.note_attributes << { name: NOTE_REASON, value: reason }

        # take money to refund and currency from presentment_money so it works with multi currencies
        if order.financial_status == PAID_STATUS
          cancel_params[:amount] = order.current_total_price_set.presentment_money.amount
          cancel_params[:currency] = order.current_total_price_set.presentment_money.currency_code
        end

        cancel_params[:restock] = true if customer_page_cancel_order_restock

        order.cancel(cancel_params)
        order.save

        {
          cancelled: true,
          financial_status: order.financial_status == PAID_STATUS ? 'refunded' : order.financial_status
        }
      end
    rescue ActiveResource::ResourceNotFound => e
      Utils::RollbarService.error(e, shop_id: @shop.id, order_external_id: external_id)
      { error: 'We cannot cancel orders made more than 60 days ago. Please contact the store through the contact form.' }
    rescue ActiveResource::ResourceInvalid => e # race condition order being fulfilled between fetching the order and cancelling it
      Utils::RollbarService.error(e, shop_id: @shop.id, order_external_id: external_id)
      { error: 'Something went wrong cancelling this order. Please reload the page and try again later, or contact the store through the contact form.' }
    rescue ActiveResource::ClientError => e
      Utils::RollbarService.error(e, shop_id: @shop.id, order_external_id: external_id)
      if e.message.squish.include?('Response code = 429. Response message = Too Many Requests.')
        return { error: 'Connection to the store is overloaded. Please try again later' }
      end

      { error: 'Something went wrong. Please try again later' }
    rescue StandardError => e
      Utils::RollbarService.error(e, shop_id: @shop.id, order_external_id: external_id)
      { error: 'Something went wrong. Please try again later' }
    end
  end
end
