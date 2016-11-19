# frozen_string_literal: true
require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Squircle
  class Application < Rails::Application
    config.api_only = true
    config.autoload_paths << Rails.root.join('app', 'jobs')

    ActiveModelSerializers.config.adapter = :json

    # Redis and Redis-Rails configurations.
    Resque.redis = ENV['REDIS_URL']
    Resque.redis.namespace = 'squircle:resque'

    # Enable GZip compression.
    config.middleware.use Rack::Deflater
    config.middleware.delete Rack::Lock

    # CORS configurations.
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i(get post put patch delete options)
      end
    end
  end
end
