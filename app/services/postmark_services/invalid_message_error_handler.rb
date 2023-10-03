module PostmarkServices
  class InvalidMessageErrorHandler
    def self.call(error:, customer: nil)
      case error.class.to_s
      when 'Postmark::InactiveRecipientError', 'Postmark::InvaidEmailAddressError'
        customer.update(skip_notification_reason: error.to_s) if customer.present?
      else
        raise error
      end
    end
  end
end
