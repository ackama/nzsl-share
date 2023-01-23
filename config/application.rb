require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NzslShare
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.time_zone = "Wellington"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Use sidekiq to process Active Jobs (e.g. ActionMailer's deliver_later)
    config.active_job.queue_adapter = :sidekiq

    # Set the default host to link to
    hostname = ENV.fetch("HOSTNAME", "http://localhost:3000")
    routes.default_url_options[:host] = hostname
    (config.action_mailer.default_url_options ||= {})[:host] = hostname

    # We want to have full control over error messages - sometimes we want to customize
    # the full error message, not just the part after the attribute
    config.active_model.i18n_customize_full_message = true

    config.contact_email = ENV.fetch("CONTACT_EMAIL", ENV.fetch("MAIL_FROM", nil))
    config.google_analytics_container_id = ENV.fetch("GOOGLE_ANALYTICS_CONTAINER_ID", nil)

    config.upload_mode = if ENV.fetch("FEATURE_MULTIPLE_UPLOAD", "false").match?(/\Atrue|y/)
                           :uppy
                         else
                           :legacy
                         end
  end
end
