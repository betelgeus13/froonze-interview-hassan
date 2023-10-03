# frozen_string_literal: true

module Customers
  class SocialLoginerService
    SETTINGS_TO_SELECT = %i[
      social_logins_customer_tags
      social_logins_multipass
      social_logins_accepts_email_marketing_default
      social_logins_forbid_registration
      social_logins_after_login_return_path
      social_logins_after_registration_return_path
    ].freeze

    ENABLED_CUSTOMER = 'enabled'

    def initialize(shopify_domain:, host:, email:, full_name:, locale:, locale_path:, provider:, uid:, return_url:)
      @shopify_domain = shopify_domain
      @shop = Shop.installed.with_active_plan.find_by(shopify_domain:)
      @setting = Setting.select(*SETTINGS_TO_SELECT).find_by(shop_id: @shop.id) if @shop
      @host = host
      @email = email
      @full_name = full_name
      @locale_path = locale_path
      @locale = locale
      @provider = provider
      @uid = uid
      @return_url = return_url.presence
      @new_password = SecureRandom.hex(8)
    end

    def call
      return { redirect_url: "https://#{@shopify_domain}/account/login" } if @shop.blank?

      if @email.blank?
        params = { error: 'Could not get user email' }
        return { redirect_url: generate_redirect_url(params) }
      end

      @shop.with_shopify_session do
        if registration_forbidden? && remote_customer.blank?
          params = { path: forbid_registration_redirect_path, error: translator.call(section: 'main', key: 'registration_forbidden') }
          return { redirect_url: generate_redirect_url(params) }
        end

        return { redirect_url: generate_multipass_redirect_url } if multipass_enabled?

        # multipass logs in indiferent of remote_customer.state
        if remote_customer && remote_customer.state != ENABLED_CUSTOMER
          remote_customer.send_invite
          params = { path: forbid_registration_redirect_path, error: translator.call(section: 'main', key: 'send_invite') }
          return { redirect_url: generate_redirect_url(params) }
        end

        create_or_update_customer
      end

      login_params = { email: @email, password: @new_password }
      { redirect_url: generate_redirect_url(login_params) }
    rescue ActiveResource::ClientError => e
      handle_error(e)
    end

    private

    def registration_forbidden?
      @setting.social_logins_forbid_registration['enabled']
    end

    def forbid_registration_redirect_path
      @setting.social_logins_forbid_registration['registration_page_path'].presence || '/account/register'
    end

    def multipass_enabled?
      multipass_settings = @setting.social_logins_multipass
      @shop.social_logins_advanced_plan? && multipass_settings['enabled'] && multipass_settings['secret'].present?
    end

    def generate_multipass_redirect_url
      customer = @shop.customers.find_by(email: @email)
      customer_params = { email: @email }
      new_tag_string = generate_new_tags_string

      customer_params[:return_to] = get_return_url(new_customer: customer.blank?)

      if customer.present?
        customer_params[:tag_string] = [customer.tags.join(','), new_tag_string].join(',')
      else
        customer_params[:tag_string] = new_tag_string
        add_name_to_customer_params(customer_params)
      end
      secret = @setting.social_logins_multipass['secret']
      token = Shopify::MultipassTokenGeneratorService.new(secret).call(customer_params)
      join_url_parts([shop_domain, locale_path, 'account/login/multipass', token])
    end

    def shop_domain
      return "https://#{@host}" if @host.present?

      @shop.https_domain
    end

    def create_or_update_customer
      @return_url = get_return_url(new_customer: remote_customer.blank?)
      if remote_customer.present?
        update_remote_customer(remote_customer)
      else
        customer_params = {
          email: @email,
          password: @new_password,
          password_confirmation: @new_password,
          tags: generate_new_tags_string,
          accepts_marketing: @setting.social_logins_accepts_email_marketing_default == true
        }
        add_name_to_customer_params(customer_params)
        remote_customer = ShopifyAPI::Customer.create!(customer_params.merge(send_email_welcome: true))
      end
    end

    def remote_customer
      return @remote_customer if @remote_customer
      return nil if @sent_remote_customer_request

      @remote_customer = ShopifyAPI::Customer.find(:first, from: :search, params: { query: @email })
      @sent_remote_customer_request = true
      @remote_customer
    end

    def add_name_to_customer_params(params)
      return if @full_name.blank?

      name_parts = @full_name.split(' ')
      params[:first_name] = name_parts.first
      params[:last_name] = name_parts.drop(1).join(' ')
    end

    def update_remote_customer(remote_customer)
      add_tags(remote_customer)
      change_password(remote_customer)
      Customers::EnsureRemoteCustomerEmailMarketingStateService.call(remote_customer:)
      remote_customer.save!
    end

    def change_password(remote_customer)
      remote_customer.password = @new_password
      remote_customer.password_confirmation = @new_password
    end

    def add_tags(remote_customer)
      new_tags_string = generate_new_tags_string
      remote_customer.tags += ',' + new_tags_string unless new_tags_string.blank?
    end

    def generate_new_tags_string
      tags = @setting.social_logins_customer_tags || SocialLoginsConstants::DEFAULT_CUSTOMER_TAGS.clone
      tags = tags.map do |tag|
        tag = tag.gsub('{ provider }', @provider)
        tag.gsub('{ user_id }', @uid)
      end
      tags.join(', ')
    end

    def generate_redirect_url(params)
      error = params.delete(:error)
      encoded_params = Base64.encode64(params.to_json)
      if error
        path = params[:path].present? ? params[:path] : 'account/login'
        query = "?frcp_social_logins=#{encoded_params}&error=#{error}"
        join_url_parts([shop_domain, locale_path, path, query])
      else
        redirect_params = {
          frcp_social_logins: encoded_params,
          locale_path:,
          locale: @locale,
          return_url: @return_url
        }
        query = "?#{redirect_params.to_param}"
        join_url_parts([shop_domain, locale_path, "#{app_proxy}/social_logins/shopify_login_form", query])
      end
    end

    def join_url_parts(parts)
      parts.map do |part|
        part.present? ? part.delete_prefix('/').delete_suffix('/').presence : nil
      end.compact.join('/')
    end

    def locale_path
      return '/' if @locale_path.blank?

      @locale_path
    end

    def handle_error(error)
      api_rate_limit = error.response.respond_to?(:code) && error.response.code == '429'
      Utils::RollbarService.error(error, shop_id: @shop.id) unless api_rate_limit
      params = { error: translator.call(section: 'main', key: api_rate_limit ? 'api_rate_limit' : 'general_error') }
      { redirect_url: generate_redirect_url(params) }
    end

    def translator
      @translator ||= WidgetTranslations::TranslatorService.new(@shop, WidgetTranslation::SOCIAL_LOGINS, @locale)
    end

    def app_proxy
      @shop.app_proxy_with_default[1..-1]
    end

    def get_return_url(new_customer:)
      return @return_url if @return_url.present?

      @return_url = new_customer ? @setting.social_logins_after_registration_return_path : @setting.social_logins_after_login_return_path

      @return_url = "#{locale_path}#{@return_url}".gsub('//', '/') if @return_url.present?

      @return_url
    end
  end
end
