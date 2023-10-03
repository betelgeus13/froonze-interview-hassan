# frozen_string_literal: true

module GemPatches
  module ShopifyApp
    module RequireInstalledShop
      extend ActiveSupport::Concern

      # we don't destroy shops on uninstallation, so the shop is still found
      included do
        before_action :check_shop_installed
      end

      def check_shop_installed
        redirect_to(shop_login) unless current_shop
      end

      def shop_login
        url = URI(::ShopifyApp.configuration.login_url)

        url.query = URI.encode_www_form(
          shop: params[:shop],
          host: params[:host],
          return_to: request.fullpath
        )

        url.to_s
      end
    end
  end
end
