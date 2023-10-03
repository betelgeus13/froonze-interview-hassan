# frozen_string_literal: true

module Customers
  class FactoryService

    FIELDS = %i[
      email
      first_name
      last_name
      orders_count
      total_spent
      country
      country_code
      phone
      tags
      accepts_marketing
      gender
      date_of_birth
      state
    ].freeze

    SUBSCRIBED = 'subscribed'

    def initialize(shop:, email_edit_enabled: true)
      @email_edit_enabled = email_edit_enabled
      @shop = shop
    end

    def create_or_update(params:)
      # It is possible to create customers without emails in Shopify customers dashboard, but it does not really make sense for us to save those customers as they won't even be able to login
      return { error: 'Customer has no email' } if params[:email].blank?

      customer = @shop.customers.find_or_initialize_by(external_id: params[:id])

      update_params = params.slice(*FIELDS)

      update_params[:accepts_marketing] = params[:accepts_email_marketing] if params.key?(:accepts_email_marketing)
      if params.key?(:email_marketing_consent)
        update_params[:accepts_marketing] =
          params.dig(:email_marketing_consent, :state) == SUBSCRIBED
      end

      update_params[:tags] = params[:tags].split(',').map(&:strip) if params[:tags].present?

      update_params.delete(:email) if !customer.new_record? && !@email_edit_enabled
      customer.update!(update_params)

      { customer: }
    rescue StandardError => e
      # Utils::RollbarService.error(e, params.merge(shop_id: @shop.id))

      { error: e.message }
    end
  end
end
