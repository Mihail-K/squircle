# frozen_string_literal: true
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

if Rails.env.test?
  require 'simplecov'
  SimpleCov.start 'rails' do
    track_files false
    add_filter  'app/uploaders'
    add_group   'Policies', 'app/policies'
    add_group   'Serializers', 'app/serializers'
    add_group   'Services', 'app/services'
  end
end

require 'spec_helper'
require 'rspec/json_expectations'
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

Dir[Rails.root.join('spec/support/concerns/**/*.rb')].uniq.sort.each do |file_name|
  require file_name
end

require 'faker'
require 'factory_girl_rails'

require 'support/api_schema_matcher'
require 'support/factory_girl'
require 'support/authentication'
require 'support/job'
require 'support/json'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Generate JSON versions of YAML JSON-Schema files.

Dir[Rails.root.join('spec/support/api/schemas/**/*.yml')].each do |file_name|
  json_name = File.join(File.dirname(file_name), File.basename(file_name, '.yml')) + '.json'

  # Skip generation if file is already up to date.
  next if File.exist?(json_name) && File.mtime(json_name) >= File.mtime(file_name)
  File.write(json_name, JSON.pretty_generate(YAML.load_file(file_name)) + "\n")
end

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  config.include JsonHelper, type: :request
  config.include JsonHelper, type: :controller

  config.include JobHelper, type: :controller
  config.include JobHelper, type: :model

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.include Rails.application.routes.url_helpers
end
