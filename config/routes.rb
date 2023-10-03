require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::AuthenticatedAdmin if Rails.env.production?

  mount Sidekiq::Web => '/sidekiq'

  root to: 'admin/app#index'

  namespace :admin do
    get '/' => 'app#index'
    get '/login' => 'login#index'
    get 'auth/google/callback' => 'oauth#google_oauth_callback'
    post '/graphql' => 'graphql#execute'
    get '/login_to_shop' => 'actions#login_to_shop'
  end
end
