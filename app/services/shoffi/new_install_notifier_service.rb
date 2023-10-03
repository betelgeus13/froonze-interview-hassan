module Shoffi
  class NewInstallNotifierService

    URL = "https://platform.shoffi.app/v1/newMerchant"
    SHOPIFY_APP_ID = Rails.application.credentials.shopify[:app_id]
    SHOFFI_APP_KEY = Rails.application.credentials.shoffi&.dig(:app_key)

    def initialize(shopify_domain, xff)
      @shop = Shop.find_by(shopify_domain: shopify_domain)
      @shopify_domain = shopify_domain
      @xff = xff
    end

    def call
      if SHOFFI_APP_KEY.blank?
        p "Skipping because SHOFFI_APP_KEY is missing. shopify_domain: #{@shopify_domain}; xff: #{@xff}"
        return
      end

      if @shop.blank?
        Utils::RollbarService.error("Error notifying Shoffi. Could not find shop with #{@shopify_domain} domain")
        return
      end

      body = {
        appId: SHOPIFY_APP_ID,
        api_key: SHOFFI_APP_KEY,
        shopName: @shopify_domain,
        XFF: @xff
      }
      response = HTTParty.post(URL, body: body).parsed_response
      if response == 'OK'
        @shop.update(shopify_x_forwarded_for: @xff)
      else
        Utils::RollbarService.error('Error notifying Shoffi', response: response)
      end
    end

  end
end
