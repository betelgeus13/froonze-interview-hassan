source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.4'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.6.4'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
# gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.13.0', require: false # '>= 1.4.4'

gem 'graphql'
gem 'graphql-batch'
gem 'graphql-client'
gem 'graphql-guard'
gem 'httparty'
gem 'shopify_app', '~> 18.1.2'
gem 'sidekiq'
gem 'sidekiq-batch'
gem 'sidekiq-cron', '~> 1.1'
gem 'slim'

# For soft deleting Active Record models
gem 'discard', '~> 1.2'

gem 'postmark-rails'

# Pagination
gem 'pagy'

# Simple Rails application configuration (only for shopify theme app extensions helper)
gem 'figaro'

# Enable colors when printing to console
gem 'colorize'

# Request rate limit
gem 'rack-attack'

gem 'omniauth-amazon', git: 'https://github.com/khier996/omniauth-amazon.git' # original repo still depends on the old omniauth version
gem 'omniauth-apple', '1.0.1'
gem 'omniauth-facebook', '~> 9.0'
gem 'omniauth-google-oauth2', '~> 1.0'
gem 'omniauth-linkedin-oauth2', '~> 1.0'
gem 'omniauth-microsoft_graph', '~> 1.1.0'
gem 'omniauth-twitter', '~> 1.4'

# for Google one tap
gem 'google-id-token', '~> 1.4.2'

# exception tracker
gem 'rollbar'

gem 'email_validator'

# Sendinblue
gem 'sib-api-v3-sdk'

# cross domain requests
gem 'rack-cors', '~> 1.1.1'

# s3
gem 'aws-sdk-s3', '~> 1'

# gems for ruby 3.1
gem 'net-imap', '~> 0.2.3', require: false
gem 'net-pop', '~> 0.1.1', require: false
gem 'net-smtp', '~> 0.3.1', require: false

# for phone validation
gem 'phonelib'

# Auto generate inline-css for emails
gem 'premailer'

# Liquid gem to populate variables for review request email
gem 'liquid'

# For Logging
gem "ahoy_matey"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'awesome_print', '~> 1.9.3', git: 'https://github.com/betelgeus13/awesome_print.git'
  gem 'awesome_rails_console', git: 'https://github.com/betelgeus13/awesome_rails_console.git'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'hirb'
  gem 'hirb-unicode-steakknife', require: 'hirb-unicode'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 3.0.0'
  gem 'spring-commands-rspec', '~> 1.0.4'
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'derailed' # memory usage by gems
  gem 'graphiql-rails'
  gem 'listen', '~> 3.3'
  gem 'rack-mini-profiler', '~> 2.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers

  gem 'database_cleaner', '~> 2.0.1'
  gem 'factory_bot_rails', '~> 6.2.0'
  gem 'faker', '~> 2.20.0'
  gem 'rspec-rails', '~> 6.0.0.rc1'
  gem 'rspec-sidekiq', '~> 3.1.0'
  gem 'simplecov', '~> 0.21.2', require: false
  gem 'timecop', '~>  0.9.5'
  gem 'webdrivers', '~> 5.0.0'
  gem 'webmock', '~> 3.14.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :production do
  gem 'rails-autoscale-sidekiq', '~> 1.0.2'
  gem 'rails-autoscale-web', '~> 1.0.2'
  gem 'scout_apm'
end
