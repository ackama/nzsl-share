# This file is copied to spec/ when you run 'rails generate rspec:install'
require_relative "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "rspec/rails"
require "capybara/rspec"
require "selenium-webdriver"
require "lighthouse/matchers/rspec"
require "axe/rspec"
require "pundit/rspec"

# Add additional requires below this line. Rails is not loaded until this point!

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
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Capybara.default_max_wait_time = 15.seconds # Default is 2 seconds
Capybara.disable_animation = true
Capybara.register_driver :chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new

  options.add_argument("--window-size=1920,1080")
  options.add_argument("--remote-debugging-port=9222")
  options.add_argument("--no-proxy-server")
  options.add_argument("--proxy-server='direct://'")
  options.add_argument("--proxy-bypass-list=*")
  options.add_argument("--headless") unless ENV["FOREGROUND"]

  Capybara::Selenium::Driver.new app, browser: :chrome, capabilities: [options]
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # Run system tests in rack_test by default
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  # System tests indicating that they use Javascript should be run with headless Chrome
  config.before(:each, type: :system, uses_javascript: true) do
    driven_by :chrome
  end

  # Allow tests to specify a particular upload mode (uppy or legacy).
  config.before(:each, :upload_mode) do |example|
    allow(Rails.application.config).to receive(:upload_mode)
      .and_return(example.metadata.fetch(:upload_mode))
  end

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

  # Make a 'view' object available to presenter specs
  config.include ActionView::TestCase::Behavior, type: :presenter
  config.include Devise::Test::ControllerHelpers, type: :presenter
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include PunditViewSpecHelper, type: :view

  config.include WaitForAjax, type: :system

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # Allow negated change helper:
  # expect { subject }.to change(..).and not_change(...)
  RSpec::Matchers.define_negated_matcher :not_change, :change
end
