# frozen_string_literal: true

module Forms
  class CreateOrUpdateEmailTemplateService
    def initialize(shop:)
      @shop = shop
    end

    def call(email_type:, subject:, message:, html:, locale:)
      template = @shop.form_email_templates.find_or_initialize_by(email_type:, locale:)

      html_inlined_css = Premailer.new(html, FormEmailTemplate::PREMAILER_OPTIONS).inline_css if html.present?
      template.update!(
        subject:,
        message:,
        html:,
        html_inlined_css:
      )

      {}
    rescue StandardError => e
      Utils::RollbarService.error(e)
      { error: 'Something went wrong. Please reload the page and try again. The development team has been informed.' }
    end
  end
end
