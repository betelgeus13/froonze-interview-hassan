# frozen_string_literal: true

module Forms
  class SubmissionService
    class SubmissionError < StandardError; end

    SETTINGS_TO_LOAD = %i[
      customer_page_enable_email_edit
      split_date_of_birth
    ].freeze

    def initialize(shop:, form_slug:, customer_external_id:, field_params:, locale:, redirect_path:)
      @shop = shop
      @setting = Setting.select(SETTINGS_TO_LOAD).find_by(shop_id: shop.id)
      @form = shop.forms.find_by(slug: form_slug)
      @customer_external_id = customer_external_id
      @field_params = field_params
      @locale = locale
      @after_registration_redirect_path = redirect_path
      @redirect_url = nil
      @error = nil
    end

    def call
      return { error: translator.call(section: 'errors', key: 'not_found') } if @form.blank?

      if @customer_external_id.blank? && @field_params['email'].blank?
        return { error: translator.call(section: 'errors', key: 'empty_email') }
      end

      return { error: translator.call(section: 'errors', key: 'activate_form') } unless @form.active?

      @shop.with_shopify_session do
        create_or_update_remote_customer
      end

      create_or_update_local_customer

      { redirect_url: @redirect_url, error: @error }.compact
    rescue StandardError => e
      Utils::RollbarService.error(SubmissionError.new(e), shop_id: @shop.id)
      { error: translator.call(section: 'errors', key: 'something_went_wrong') }
    end

    private

    def translator
      @translator ||= WidgetTranslations::TranslatorService.new(@shop, WidgetTranslation::CUSTOM_FORMS, @locale)
    end

    def create_or_update_remote_customer
      if @form.for_registration?
        remote_customer = Shopify::Forms::CustomerRequesterService.get_customer_by_email(@field_params['email'])

        if remote_customer.present?
          @error = translator.call(section: 'errors', key: 'account_exists', variables: { email: @field_params['email'] })

          if remote_customer['state'].downcase != Customers::SocialLoginerService::ENABLED_CUSTOMER
            customer = ShopifyAPI::Customer.find(:first, from: :search, params: { query: @field_params['email'] })
            customer.send_invite
            @error = translator.call(section: 'errors', key: 'send_invite', variables: { email: @field_params['email'] })
          end

          return @error
        end

        @form.account_approval? ? create_awaiting_approval_customer : create_remote_customer
      else
        remote_customer = Shopify::Forms::CustomerRequesterService.get_customer_by_external_id(@customer_external_id)
        return @error = translator.call(section: 'errors', key: 'cannot_find_customer') if remote_customer.blank?

        ret = Customers::UpdateRemoteCustomerService.new(
          shop: @shop,
          split_date_of_birth: @setting.split_date_of_birth,
          email_edit_enabled: email_edit_enabled?
        ).call(remote_customer:, params: @field_params)

        return @error = ret[:error] if ret[:error]
      end
    end

    def create_remote_customer
      ret = Customers::CreateRemoteCustomerService.new(
        shop: @shop,
        split_date_of_birth: @setting.split_date_of_birth,
        send_invite: @form.email_verification?
      ).call(params: @field_params)

      return @error = ret[:error] if ret[:error]

      unless @form.email_verification?
        encoded_params = Base64.encode64({ email: @field_params['email'], password: @field_params['password'] }.to_json)
        params = {
          frcp_custom_forms: encoded_params,
          locale: @locale
        }
        if @form.registration_default?
          redirect_path = @after_registration_redirect_path || @form.redirect_path
          params[:redirect_path] = redirect_path if redirect_path.present?
        end
        redirect_url = "#{@shop.app_proxy_with_default}/custom_forms/shopify_login_form?#{params.to_param}"
      end
      @redirect_url = redirect_url
      @customer_external_id = ret[:customer_external_id]
    end

    def create_awaiting_approval_customer
      ret = Forms::CreateAwaitingApprovalCustomerService.new(shop: @shop, form: @form).call(params: @field_params, locale: @locale)

      @error = ret[:error] if ret[:error]
    end

    def create_or_update_local_customer
      return if @form.account_approval?

      params = @field_params.dup.deep_symbolize_keys
      params[:id] = @customer_external_id
      Customers::FactoryService.new(shop: @shop, email_edit_enabled: email_edit_enabled?).create_or_update(params:)
    end

    def email_edit_enabled?
      @setting.customer_page_enable_email_edit
    end
  end
end
