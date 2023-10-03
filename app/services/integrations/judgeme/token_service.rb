module Integrations
  module Judgeme
    class TokenService
      def self.encode(shop_id:)
        crypt = ActiveSupport::MessageEncryptor.new(Rails.application.credentials.judgeme[:oauth_secret])
        encrypted_data = crypt.encrypt_and_sign({ shop_id: }.to_json, purpose: :judgeme_oauth, expires_in: 1.minutes)

        { token: Base64.urlsafe_encode64(encrypted_data) }
      end

      def self.decode(token:)
        base_64_decoded = Base64.urlsafe_decode64(token)
        crypt = ActiveSupport::MessageEncryptor.new(Rails.application.credentials.judgeme[:oauth_secret])
        decoded_data = crypt.decrypt_and_verify(base_64_decoded, purpose: :judgeme_oauth)

        result = JSON.parse(decoded_data)

        { shop_id: result['shop_id'] }
      rescue StandardError => e
        { error: 'Token is not valid' }
      end
    end
  end
end
