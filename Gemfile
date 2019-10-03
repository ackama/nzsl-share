source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.3"

gem "rails", "6.0.0"
gem "puma"
gem "pg", ">= 0.18"
gem 'dotenv-rails', require: "dotenv/rails-now"
gem "bootsnap", require: false
gem "sassc-rails"
gem "redis"
gem "sidekiq"
gem "turbolinks"
gem "webpacker"
gem "devise"
gem "nokogiri", "~> 1.10"
gem "faraday"
gem "faraday_middleware"
gem "pundit"

gem "rack-canonical-host"

group :development do
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "simplecov", require: false
  gem "rubocop", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "letter_opener"

  # Required in Rails 5 by ActiveSupport::EventedFileUpdateChecker
  gem "listen"
  gem "overcommit", require: false
end

group :development, :test do
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "pry-rails"
end

group :test do
  gem "capybara"
  gem "mock_redis"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "axe-matchers"
  gem "lighthouse-matchers"
end
