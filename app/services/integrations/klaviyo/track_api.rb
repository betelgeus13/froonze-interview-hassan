module Integrations
  module Klaviyo
    class TrackApi
      URL = 'https://a.klaviyo.com/api/track'

      def call(track_payload:)
        res = HTTParty.post(
          URL,
          {
            body: "data=#{track_payload.to_json}",
            headers: {
              'Content-Type' => 'application/x-www-form-urlencoded'
            }
          }
        ).parsed_response

        { result: res }
      rescue StandardError => e
        { error: e.message }
      end
    end
  end
end
