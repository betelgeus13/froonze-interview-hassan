module PostmarkServices
  class SenderSignatureFactoryService
    DEFAULT_PATH = 'pm-bounces'

    def create_or_update(email:, name: nil)
      return { error: 'Email is required' } if email.blank?

      sender_signature = SenderSignature.find_or_initialize_by(email:)
      domain = email.split('@').last

      ret = postmark_data(email:, name:, external_id: sender_signature.external_id)

      return { error: ret[:error] } if ret[:error]

      response = ret[:response]

      return_path_domain = response[:return_path_domain].gsub(".#{domain}", '').presence || DEFAULT_PATH
      dkim_host = response[:dkim_host].presence || response[:dkim_pending_host]
      dkim_host = dkim_host.gsub(".#{domain}", '')

      sender_signature.update!(
        external_id: response[:id],
        dkim_host:,
        dkim_text_value: response[:dkim_text_value].presence || response[:dkim_pending_text_value],
        dkim_verified: response[:dkim_verified],
        return_path_domain:,
        return_path_domain_cname_value: response[:return_path_domain_cname_value],
        return_path_domain_verified: response[:return_path_domain_verified],
        confirmed: response[:confirmed]
      )

      { sender_signature: }
    rescue StandardError => e
      { error: e.to_s }
    end

    private

    def postmark_data(email:, name:, external_id:)
      api_client = PostmarkServices::SenderSignatureApi.new
      external_id ? api_client.get(external_id:) : api_client.create(name:, from_email: email)
    end
  end
end
