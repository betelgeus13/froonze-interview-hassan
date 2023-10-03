# frozen_string_literal: true
module Sendinblue
  class ContactManagerService

    MAIN_LIST_ID = Rails.application.credentials.sendinblue[:main_list_id]

    def initialize(shop)
      @shop = shop
      @email = @shop.email
      @api_instance = SibApiV3Sdk::ContactsApi.new
    end

    def call
      if @shop.installed? && @shop.accepts_marketing? && !@shop.development_shop?
        create_or_update
      else
        delete
      end
    end

    private

    def create_or_update
      if contact_exists?
        update
      else
        create
      end
    end

    def delete
      @api_instance.delete_contact(@email)
    rescue SibApiV3Sdk::ApiError
    end

    def contact_exists?
      @api_instance.get_contact_info(@email).present?
    rescue SibApiV3Sdk::ApiError => e
      return false if e.message == "Not Found"
      raise e
    end

    def create
      create_params = { 'email' => @email, 'listIds' => [MAIN_LIST_ID], 'attributes' => contact_attributes } # symbol keys don't work
      @api_instance.create_contact(create_params)
    end

    def update
      update_params = { 'listIds' => [MAIN_LIST_ID], 'attributes' => contact_attributes } # symbol keys don't work
      @api_instance.update_contact(@email, update_params)
    end

    def contact_attributes
      name_parts = @shop.owner.split(' ')
      {
        shopify_domain: @shop.shopify_domain,
        firstname: name_parts.first,
        lastname: name_parts.drop(1).join(' '),
        shopify_plan: @shop.shopify_plan,
        primary_locale: @shop.primary_locale,
        country_code: @shop.primary_locale,
        currency: @shop.currency,
        created_at: @shop.created_at,
        beta_tester: @shop.beta_tester,
      }
    end

  end
end
