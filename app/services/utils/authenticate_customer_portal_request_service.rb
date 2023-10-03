module Utils
  class AuthenticateCustomerPortalRequestService

    def self.call(string:, froonze_token:)
      current_signature = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        Rails.application.credentials.theme_app_extension_hmac_secret[:current],
        string.to_s
      )

      old_signature = OpenSSL::HMAC.hexdigest(
        OpenSSL::Digest.new('sha256'),
        Rails.application.credentials.theme_app_extension_hmac_secret[:old],
        string.to_s
      )

      valid = ActiveSupport::SecurityUtils.secure_compare(current_signature, froonze_token) ||
        ActiveSupport::SecurityUtils.secure_compare(old_signature, froonze_token)

      return { error: 'Your request could not be authenticated. Please reload and try again.' } unless valid

      {}
    end
  end
end
