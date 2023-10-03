# frozen_string_literal: true

#  api doc https://judge.me/api/docs#section/Authentication

module Integrations
  module Judgeme
    class LoyaltyWebhooksService
      WEBHOOK_KEYS = [
        'review/created',
        'review/updated'
      ].freeze

      WEBHOOKS_API_URL = 'https://judge.me/api/v1/webhooks'
      ALREADY_EXISTS = 'Key and Url duplicated'
      WEBHOOK_NOT_FOUND = 'Webhook not found'
      NOT_AWESOME = 'Shop is not awesome. Please upgrade to create webhooks.'

      def initialize(integration:)
        @integration = integration
      end

      def call
        return { error: 'Service is only for loyalty judgeme integration' } unless @integration.loyalty_judgeme?

        if @integration.settings['access_token'].blank?
          return { error: 'Integration is not econnected. Please reload the page and start the oAuth process' }
        end

        @integration.enabled? ? create_all : delete_all
      end

      private

      def get_all
        response = request(method: :get, data: nil)
        return { error: response['error'] } if response['error']

        { webhooks: response['webhooks'] }
      end

      def create_all
        ret = get_all
        return { error: ret[:error] } if ret[:error].present?

        missing_webhooks = WEBHOOK_KEYS - ret[:webhooks].map { |webhook| webhook['key'] }
        webhooks_data = missing_webhooks.map do |webhook_key|
          {
            'key' => webhook_key,
            'url' => Rails.application.routes.url_helpers.judgeme_webhook_url
          }
        end

        @integration.settings['webhooks'] ||= {}

        ret[:webhooks].each do |webhook|
          @integration.settings['webhooks'][webhook['key']] = { 'url' => webhook['url'] }
        end

        webhooks_data.map do |data|
          response = request(method: :post, data:)
          @integration.settings['webhooks'][data['key']] = process_create_response(response:, url: data['url'])
        end

        @integration.save!

        {}
      end

      def delete_all
        ret = get_all
        return { error: ret[:error] } if ret[:error].present?

        webhooks_data = ret[:webhooks].map do |webhook|
          {
            'key' => webhook['key'],
            'url' => webhook['url']
          }
        end

        @integration.settings['webhooks'] ||= {}

        webhooks_data.map do |data|
          response = request(method: :delete, data:)
          is_deleted = response['error'].blank? || [WEBHOOK_NOT_FOUND, NOT_AWESOME].include?(response['error'])
          @integration.settings['webhooks'].delete(data['key']) if is_deleted
        end

        @integration.settings['webhooks'] = {} if webhooks_data.blank?
        @integration.save!

        {}
      end

      def process_create_response(response:, url:)
        webhook_created = response['error'].blank? || response['error'] == [ALREADY_EXISTS]

        if webhook_created
          { 'url' => url }
        else
          error = response['error']
          error = 'The Judge.me plan is not Awesome. Please upgrade in Judge.me to setup the integration' if error&.include?(NOT_AWESOME)
          { 'error' => error }
        end
      end

      def request(method:, data:)
        params = {
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{@integration.settings['access_token']}"
          }
        }
        params[:body] = data.to_json if data

        HTTParty.send(method, WEBHOOKS_API_URL, params).parsed_response
      end
    end
  end
end
