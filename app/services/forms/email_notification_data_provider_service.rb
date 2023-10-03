module Forms
  class EmailNotificationDataProviderService
    def call(shop:, subject:, message:, email_type:, locale:, to:, first_name:, last_name:, html: nil)
      unless html
        ret = ::Forms::EmailTemplateFetcherService.new(shop:).get_with_locale(email_type:, locale:)
        return { error: ret[:error] } if ret[:error]

        form_email_template = ret[:result]
        html ||= form_email_template.html_inlined_css
        subject ||= form_email_template.subject
        message ||= form_email_template.message
      end

      logo_url = ::Setting.select(:email_logo).find_by(shop_id: shop.id).email_logo

      variables = {
        first_name:,
        last_name:,
        message:,
        full_name: [first_name, last_name].compact.join(' '),
        shop_name: shop.name,
        shop_https_domain: shop.https_custom_domain,
        reply_to: shop.reply_to,
        logo_url:
      }.stringify_keys

      {
        to:,
        from: shop.from_email,
        reply_to: shop.reply_to,
        subject:,
        body: Liquid::Template.parse(html).render(variables)
      }
    end
  end
end
