# frozen_string_literal: true
workers Integer(ENV['WEB_CONCURRENCY'] || 2) unless Gem.win_platform?
threads 1, Integer(ENV['RAILS_MAX_THREADS'] || 5)

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  ActiveRecord::Base.establish_connection

  if defined?(Resque)
    Resque.redis = ENV['REDIS_URL']
    Resque.redis.namespace = 'squircle:resque'
  end
end
