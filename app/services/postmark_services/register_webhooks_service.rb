# this service should only be called once, if one wants to receive webhooks from Postmark
module PostmarkServices
  class RegisterWebhooksService
    STREAMS = %w[
      loyalty
      wishlist
    ]

    def self.call
      client = PostmarkServices::Client.server

      STREAMS.map do |stream|
        client.create_webhook(
          { url: Rails.application.routes.url_helpers.postmark_webhook_url,
            message_stream: stream,
            triggers: {
              Open: { Enabled: true, PostFirstOpenOnly: true },
              Click: { Enabled: true },
              Bounce: { Enabled: true, IncludeContent: false },
              SpamComplaint: { Enabled: true, IncludeContent: false }
            } }
        )
      end
    end
  end
end
