module SenderEmails
  class FactoryService
    def initialize(shop:, email:)
      @shop = shop
      @email = email
    end

    def create_or_update
      sender_email = existing_sender_email || from_existing_sender_signatures
      return { sender_email: } if sender_email

      ret = from_new_sender_signature
      return { error: ret[:error] } if ret[:error]

      { sender_email: ret[:sender_email] }
    end

    private

    def deactivate_all_sender_emails
      SenderEmails::DeactivateService.new.call(shop: @shop)
    end

    def existing_sender_email
      existing_sender_email_id = @shop.sender_emails.with_email(@email).first&.id
      return unless existing_sender_email_id

      ActiveRecord::Base.transaction do
        deactivate_all_sender_emails
        existing_sender_email = SenderEmail.find_by(id: existing_sender_email_id)
        existing_sender_email.update!(active: true)
        existing_sender_email
      end
    end

    def from_existing_sender_signatures
      sender_signature = SenderSignature.find_by(email: @email)
      return nil if sender_signature.blank?

      sender_email = @shop.sender_emails.new(
        sender_signature:,
        active: true
      )

      ActiveRecord::Base.transaction do
        deactivate_all_sender_emails
        sender_email.save!
      end

      sender_email
    end

    def from_new_sender_signature
      setting = Setting.select(:send_from_name).find_by(shop_id: @shop.id)
      name = setting.send_from_name_with_default(shop: @shop)
      ret = PostmarkServices::SenderSignatureFactoryService.new.create_or_update(email: @email, name:)
      return { error: ret[:error] } if ret[:error]

      sender_email = nil

      ActiveRecord::Base.transaction do
        deactivate_all_sender_emails
        sender_email = @shop.sender_emails.create!(
          sender_signature: ret[:sender_signature],
          active: true
        )
      end

      { sender_email: }
    end
  end
end
