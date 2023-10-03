class ApplicationController < ActionController::Base
  def current_shop
    @current_shop ||= Shop.installed.find_by(shopify_domain: current_shopify_domain)
  end

  def set_embedded_data
    @shop_info = MerchantDashboard::DataService.new(current_shop).shop_info
    @global_constants = MerchantDashboard::DataService::GLOBAL_CONSTANTS.merge(host: params[:host])
    @texts = MerchantDashboard::TextsLoaderService.call(current_shop.admin_locale)
    @sleekplan_sso_token = Sleekplan::SsoTokenGeneratorService.new(current_shop).call
  end
end
