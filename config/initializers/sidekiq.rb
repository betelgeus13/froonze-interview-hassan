require 'sidekiq'

if Rails.env.production?
  url = ENV['REDISCLOUD_URL'] || ENV['REDIS_URL'] || 'redis://localhost:6379'
  Sidekiq.configure_server do |config|
    config.redis = { url: url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: url, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
  end
end

schedule_file = 'config/schedule.yml'
if File.exist?(schedule_file) && Sidekiq.server?
  Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
end
