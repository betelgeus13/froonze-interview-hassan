url = ENV['REDISCLOUD_URL'] || ENV['REDIS_URL'] || 'redis://localhost:6379'
$redis = Redis.new(url: url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
