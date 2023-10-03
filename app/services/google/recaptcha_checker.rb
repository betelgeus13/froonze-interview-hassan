# frozen_string_literal: true

module Google
  class RecaptchaChecker
    BASE_URL = 'https://www.google.com/recaptcha/api/siteverify'
    API_SECRET = Rails.application.credentials.google_recaptcha_secret_key
    MIN_SCORE = 0.5.freeze

    def initialize(token)
      @token = token
    end

    def valid?
      return false unless @token.present?
      body = { secret: API_SECRET, response: @token }
      response = HTTParty.post(BASE_URL, body: body).parsed_response
      response['success'] && response['score'] >= MIN_SCORE
    end
  end
end

