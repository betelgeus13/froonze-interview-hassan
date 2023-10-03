# frozen_string_literal: true

# in development make sure your cache is enabled. Run `rails dev:cache` if it's not
class Rack::Attack
  THROTTLE_LIMIT = (ENV['THROTTLE_LIMIT'] || 300)
  THROTTLE_PERIOD_SECONDS = (ENV['THROTTLE_PERIOD_SECONDS'] || 60).seconds
  THROTTLE_PATHS = Set['/graphql', '/api/graphql'].freeze

  SOCIAL_LOGINS_THROTTLE_LIMIT = 10
  SOCIAL_LOGINS_THROTTLE_PERIOD_SECONDS = 60.seconds

  throttle('requests by ip', limit: THROTTLE_LIMIT, period: THROTTLE_PERIOD_SECONDS) do |request|
    request.ip if request.path.in?(THROTTLE_PATHS)
  end

  throttle('requests by ip for oAuth', limit: SOCIAL_LOGINS_THROTTLE_LIMIT, period: SOCIAL_LOGINS_THROTTLE_PERIOD_SECONDS) do |request|
    request.ip if request.path.starts_with?('/social_logins/login/')
  end
end
