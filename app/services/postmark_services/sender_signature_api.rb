module PostmarkServices
  class SenderSignatureApi
    SIGNATURE_EXISTS_ERRROR = 'This signature already exists'
    PUBLIC_DOMAINS = [
      'gmail.com',
      'yahoo.com',
      'outlook.com'
    ]

    PERSONAL_NOTE = 'This confirmation is part of the email validation you initiated in our Customer Accounts Concierge app. If you have any questions or need any help, feel free to reach out to us at support@froonze.com.'

    def initialize
      @client = PostmarkServices::Client.account
    end

    def create(name:, from_email:)
      domain = from_email.split('@').last
      return { error: 'Cannot use emails with public domain' } if PUBLIC_DOMAINS.any? { |d| d == domain }

      { response: @client.create_sender(name:, from_email:, confirmation_personal_note: PERSONAL_NOTE) }
    rescue Postmark::ApiInputError => e
      Utils::RollbarService.error(e, from_email:)

      if e.to_s.include?(SIGNATURE_EXISTS_ERRROR)
        return { error: "#{SIGNATURE_EXISTS_ERRROR}. Please contact support@froonze.com to fix the problem." }
      end

      { error: e.to_s }
    end

    def get(external_id:)
      { response: @client.get_sender(external_id) }
    rescue StandardError => e
      Utils::RollbarService.error(e, external_id:)

      { error: e.to_s }
    end

    def resend_sender_confirmation(external_id:)
      { response: @client.resend_sender_confirmation(external_id) }
    rescue Postmark::TimeoutError => e
      Utils::RollbarService.error(e, external_id:)

      { error: 'Please try again. Please contact support@froonze.com if this error persists.' }
    rescue StandardError => e
      Utils::RollbarService.error(e, external_id:)

      { error: e.to_s }
    end

    def delete(external_id:)
      @client.delete(external_id)
    end
  end
end
