source 'https://rubygems.org'

gem 'active_model_serializers', '~> 0.10.0'
gem 'active_record_union'
gem 'awesome_print'
gem 'bcrypt', '~> 3.1.7'
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'
gem 'carrierwave_backgrounder'
gem 'doorkeeper'
gem 'kaminari'
gem 'mini_magick'
gem 'permissible', github: 'mihail-k/permissible'
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
  gem 'rspec'
  gem 'rspec-rails'
  gem 'sqlite3'
end

group :production do
  gem 'fog-aws'
  gem 'pg'
  gem 'puma'
end
