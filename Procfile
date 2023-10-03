web: bundle exec rails server -e production
worker: bundle exec sidekiq -t 25 -e production
release: rails db:migrate
