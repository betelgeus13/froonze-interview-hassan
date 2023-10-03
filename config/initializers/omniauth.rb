# frozen_string_literal: true

Rails.application.config.middleware.use(OmniAuth::Builder) do
  admin_google_credentials = Rails.application.credentials.admin_google_oauth
  provider :google_oauth2, admin_google_credentials[:id], admin_google_credentials[:secret],
           {
             callback_path: '/admin/auth/google/callback'
           }
end
