# frozen_string_literal: true
module OmniAuth
  module Strategies
    class FroonzeGoogle < OmniAuth::Strategies::GoogleOauth2

      option :name, 'froonze_google'

      def on_callback_path?
        request.base_url == Rails.application.credentials.https_url && current_path == '/social_logins/google/callback'
      end

    end
  end
end
