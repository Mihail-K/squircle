source 'https://rubygems.org'
ruby '2.3.1'

gem 'active_model_serializers', '~> 0.10.0'
gem 'awesome_print'
gem 'bcrypt', '~> 3.1.7'
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'
gem 'carrierwave_backgrounder'
gem 'doorkeeper'
gem 'kaminari'
gem 'mini_magick'
gem 'permissible', github: 'mihail-k/permissible'
gem 'pg'
gem 'puma'
gem 'pundit'
gem 'rack-cors', require: 'rack/cors'
gem 'rails'
gem 'redcarpet'
gem 'redis', '~>3.2'
gem 'redis-rails'
gem 'resque'
gem 'resque-scheduler'
gem 'sass-rails', '~> 5.0'
gem 'validates_timeliness'
gem 'tzinfo-data', platforms: %i(mingw mswin x64_mingw)

group :development do
  gem 'annotate'
  gem 'spring'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'json-schema'
  gem 'resque_spec'
  gem 'simplecov', require: false
end

group :development, :test do
  gem 'byebug'
  gem 'dotenv-rails'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'parallel_tests'
  gem 'rspec'
  gem 'rspec-rails'
end

group :production do
  gem 'fog-aws'
end
