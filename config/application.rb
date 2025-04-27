require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module NzslShare
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2
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

    # Set the action mailer queue name
    config.action_mailer.deliver_later_queue_name = :mailers

    # We want to have full control over error messages - sometimes we want to customize
    # the full error message, not just the part after the attribute
    config.active_model.i18n_customize_full_message = true

    config.contact_email = ENV.fetch("CONTACT_EMAIL", ENV.fetch("MAIL_FROM", nil))
    config.google_analytics_container_id = ENV.fetch("GOOGLE_ANALYTICS_CONTAINER_ID", nil)

    # NZSL Share uses .js.erb responses, so we need data-remote=true set
    # on forms for @rails/rails_ujs to handle these responses
    config.action_view.form_with_generates_remote_forms = true

    ##
    # In Rails 7, the hash digest class was changed to SHA256. We have many
    # ActiveStorage keys that use this hash value as part of a variation key, so
    # we are sticking with SHA1.
    # The pathway to supporting SHA256 would involve recalculating the new digest with
    # SHA256 and either moving or regenerating all ActiveStorage::Blob variants.
    config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA1

    config.dictionary_host = ENV.fetch("NZSL_DICTIONARY_HOST", "https://nzsl.nz")

    config.upload_mode = if ENV.fetch("FEATURE_MULTIPLE_UPLOAD", "true").match?(/\A(?:true|y)\Z/)
                           :uppy
                         else
                           :legacy
                         end
  end
end
