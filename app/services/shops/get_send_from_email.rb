# frozen_string_literal: true

module Shops
  class GetSendFromEmail
    DEFAULT_EMAIL = Rails.application.credentials.default_sender_email

    def self.email_with_name(shop:, name: nil)
      name ||= name(shop:)
      email = email_from_sender_email(shop:) || DEFAULT_EMAIL

      "#{name} <#{email}>"
    end

    def self.email_from_sender_email(shop:)
      sender_email = shop.sender_emails.active.first
      email = sender_email.email if sender_email && (sender_email.confirmed || sender_email.dkim_verified)

      email
    end

    def self.name(shop:)
      setting = Setting.select(:send_from_name).find_by(shop_id: shop.id)
      setting.send_from_name_with_default(shop:)
    end
  end
end
