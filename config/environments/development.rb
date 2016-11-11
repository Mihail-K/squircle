# frozen_string_literal: true
Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local = true

  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  config.action_view.raise_on_missing_translations = true

  ActiveSupport::Notifications.subscribe 'cache_write.active_support' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Rails.logger.debug(<<-TEXT.squish.red)
      [#{event.payload[:namespace]}] Cache Write =>
      #{event.payload[:key].split('/')[0].camelize rescue 'Object'}
      (#{event.payload[:key]})
    TEXT
  end

  ActiveSupport::Notifications.subscribe 'cache_fetch_hit.active_support' do |*args|
    event = ActiveSupport::Notifications::Event.new(*args)
    Rails.logger.debug(<<-TEXT.squish.green)
      [#{event.payload[:namespace]}] Cache Hit =>
      #{event.payload[:key].split('/')[0].camelize rescue 'Object'}
      (#{event.payload[:key]})
    TEXT
  end
end
