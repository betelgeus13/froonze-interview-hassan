module SenderEmails
  class DeactivateService
    def call(shop:)
      shop.sender_emails.active.update_all(active: false, updated_at: Time.current)
      {}
    end
  end
end
