require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true


  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Use a different cache store in production.
  config.cache_store = :redis_cache_store, {
    url: 'redis://localhost:6379',
    connect_timeout:    30,  # Defaults to 20 seconds
    read_timeout:       0.2, # Defaults to 1 second
    write_timeout:      0.2, # Defaults to 1 second
    reconnect_attempts: 1,   # Defaults to 0

    error_handler: -> (method:, returning:, exception:) {
      Rails.logger.info "Redis error: #{exception}"
    }
  }
  config.action_controller.perform_caching = true

  # we expect these files to be in the root
  config.embeds_file_path = Rails.root.join("alchemist-embeddings.csv")
  config.pages_file_path = Rails.root.join("alchemist-pages.csv")
end
