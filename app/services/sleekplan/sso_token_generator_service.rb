module Sleekplan
  class SsoTokenGeneratorService

    PRIVATE_KEY = Rails.application.credentials.sleekplan.try(:[], :private_key)

    def initialize(shop)
      @shop = shop
    end

    def call
      return if PRIVATE_KEY.blank?
      user_data = {
        mail: @shop.email,
        name: @shop.owner_first_name,
        full_name: @shop.owner,
        id: @shop.id,
      }
      JWT.encode(user_data, PRIVATE_KEY, 'HS256')
    end

  end
end
