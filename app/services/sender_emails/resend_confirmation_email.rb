module SenderEmails
  class ResendConfirmationEmail
    def call(sender_signature:)
      return { error: "Email(#{sender_signature.email}) is already confirmed" } if sender_signature.confirmed?

      ret = PostmarkServices::SenderSignatureApi.new.resend_sender_confirmation(external_id: sender_signature.external_id)
      return { error: ret[:error] } if ret[:error]

      {}
    end
  end
end
