source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby File.read(".ruby-version")

gem "aasm"
gem "administrate", "~> 1.0.0"
gem "aws-sdk-s3"
gem "bootsnap", require: false
gem "connection_pool", "~> 2.0"
gem "csv"
gem "devise"
gem "devise_invitable"
gem "dotenv-rails", require: "dotenv/rails-now"
gem "faraday"
gem "faraday_middleware"
gem "image_processing"
gem "inline_svg"
gem "kaminari"
gem "nokogiri", "~> 1.18"
gem "observer"
gem "pg", "~> 1.3.0"
gem "puma"
gem "pundit"
gem "rails", "~> 8.1.0"
gem "raygun4ruby"
gem "redis"
gem "sassc-rails"
gem "selectize-rails"
gem "shakapacker", "~> 9.0"
gem "sidekiq"
gem "sidekiq-batch"
gem "sqlite3"
gem "turbolinks"

gem "rack-canonical-host"

group :development do
  gem "brakeman", require: false
  gem "bundler-audit", require: false
  gem "letter_opener"
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "simplecov", require: false

  # Required in Rails 5 by ActiveSupport::EventedFileUpdateChecker
  gem "listen"
  gem "overcommit", require: false
end

group :development, :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
  gem "rspec-rails"
  gem "rspec-retry"
end

group :test do
  gem "axe-matchers"
  gem "capybara"
  gem "lighthouse-matchers"
  gem "mock_redis"
  gem "selenium-webdriver"
end
