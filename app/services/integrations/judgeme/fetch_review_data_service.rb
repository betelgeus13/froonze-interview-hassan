# frozen_string_literal: true

#  api doc https://judge.me/api/docs#section/Authentication
module Integrations
  module Judgeme
    class FetchReviewDataService
      API_URL = 'https://judge.me/api/v1/reviews'

      def initialize(shop:, review_id:)
        @shop = shop
        @integration = shop.integrations.find_by(widget_type: Integration::LOYALTY_TYPE, key: IntegrationConstants::LOYALTY_JUDGEME)
        @review_id = review_id
      end

      def call
        return { error: 'Cannot find integration' } if @integration.blank?

        return { error: 'Integration is not econnected.' } if @integration.settings['access_token'].blank?

        params = {
          headers: {
            'Content-Type' => 'application/json',
            'Authorization' => "Bearer #{@integration.settings['access_token']}"
          }
        }

        ret = HTTParty.get("#{API_URL}/#{@review_id}", params).parsed_response

        return { error: ret[:error] } if ret[:error]

        {
          data: {
            verified: ret.dig('review', 'verified'),
            source: ret.dig('review', 'source'),
            has_pictures: ret.dig('review', 'has_published_pictures') || ret.dig('review', 'pictures')&.size.to_i > 0,
            has_videos: ret.dig('review', 'has_published_videos') || ret.dig('review', 'videos')&.size.to_i > 0
          }
        }
      end
    end
  end
end
