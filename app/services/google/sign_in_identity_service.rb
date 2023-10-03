module Google
  class SignInIdentityService

    DEFAULT_CLIENT_ID = Rails.application.credentials.social_logins[:google][:id]

    attr_reader :error

    def initialize(shop, credential)
      @shop = shop
      @credential = credential
      @client_id = fetch_client_id
      @payload = extract_payload
    end

    def email
      @payload['email']
    end

    def name
      @payload['name']
    end

    def user_id
      @payload['sub']
    end

    private

    def extract_payload
      validator = GoogleIDToken::Validator.new
      decoded_creds = JWT.decode(@credential, nil, false)
      required_audience = decoded_creds[0]['aud']
      validator.check(@credential, required_audience, @client_id)
    rescue GoogleIDToken::ValidationError => error
      @error = 'Error with validating Google client id'
    end


    def fetch_client_id
      setting = Setting.select(:social_logins_providers).find_by(shop_id: @shop.id)
      google_settings = setting.social_logins_providers['google'].to_h
      google_settings['app_id'].presence || DEFAULT_CLIENT_ID
    end

  end
end
