module Admin
  class AppController < Admin::BaseController
    layout 'admin'

    def index
      return redirect_to admin_login_url if admin.blank?

      @global_constants = {
        https_url: Rails.application.credentials.https_url,
        theme_customization_types: ShopifyThemeCustomization::TYPES,
        shopify_theme_app_extension_uuid: Rails.application.credentials.shopify_theme_app_extension_uuid
      }
    end
  end
end
