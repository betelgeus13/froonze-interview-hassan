# frozen_string_literal: true

require_relative "boot"

require "rails/all"
require_relative '../lib/core_extensions/string/integer_check'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CustomerPortal
  class Application < Rails::Application
    # Set credentials config path first
    if ENV['PIPE_ENV'].present?
      config.credentials.content_path = Rails.root.join("config/credentials/#{ENV["PIPE_ENV"]}.yml.enc")
      config.credentials.key_path = Rails.root.join("config/credentials/#{ENV["PIPE_ENV"]}.key")
    end

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    config.active_job.queue_adapter = :sidekiq

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    Rails.application.config.action_controller.asset_host = Rails.application.credentials.asset_host.presence ||  Rails.application.credentials.https_url


    Rails.application.routes.default_url_options[:host] = Rails.application.credentials.https_url

    config.middleware.use Rack::Deflater
    config.public_file_server.headers = {
      # CORS:
      'Access-Control-Allow-Origin' => '*'
    }

    String.include CoreExtensions::String::IntegerCheck
  end
end
