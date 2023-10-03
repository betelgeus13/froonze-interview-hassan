module PostmarkServices
  class Client
    EXTRA_OPTIONS = {
      secure: true,
      http_open_timeout: 5,
      http_read_timeout: 5
    }

    def self.account
      Postmark::AccountApiClient.new(Rails.application.credentials.postmark_api_token[:account], EXTRA_OPTIONS)
    end

    def self.server
      Postmark::ApiClient.new(Rails.application.credentials.postmark_api_token[:server], EXTRA_OPTIONS)
    end
  end
end
