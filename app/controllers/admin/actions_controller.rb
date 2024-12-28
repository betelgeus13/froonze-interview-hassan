module Admin
  class ActionsController < Admin::BaseController
    before_action :check_admin_access
    def login_to_shop
      # this will throw a 404 an error is we cannot find the shop
      shop = Shop.find(params[:shop_id])
      # TODO: login will fail if the shop has outdated access scopes
      #  we should not allow redirect in that situation

      session[:shop_id] = params[:shop_id]
      # the following two keys are updated so they are in tune with shop_id
      session[:shopify_domain] = shop.shopify_domain
      session['shopify.omniauth_params'] = nil
      redirect_to Rails.application.routes.url_helpers.root_url
    end

    def track_action
      ahoy.track "Login to Shop", {
        shop_id: params[:shop_id],
        shopify_domain: session[:shopify_domain],
      }
    end
  end
end
