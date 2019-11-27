[![Codeship Status for ackama/nzsl-share](https://app.codeship.com/projects/93cf1f10-a9e8-0137-6493-0accbd4a81ee/status?branch=master)](https://app.codeship.com/projects/361577)

# NZSL Share

This is a Rails 6 app.

## Documentation

This README describes the purpose of this repository and how to set up a development environment. Other sources of documentation are as follows:

* UI and API designs are in `doc/`
* The authorisation policy for this app can also be found in `doc/` - this details the types of users and the permissions they have.

## Prerequisites

This project requires:

* Ruby 2.6.5, preferably managed using [rbenv][]
* Google Chrome for headless Capybara testing
* PostgreSQL must be installed and accepting connections
* Redis must be installed and accepting connections

On a Mac, you can obtain all of the above packages using [Homebrew][].

If you need help setting up a Ruby development environment, check out this [Rails OS X Setup Guide](https://mattbrictson.com/rails-osx-setup-guide).

## Getting started

### bin/setup

Run the `bin/setup` script. This script will:

* Check you have the required Ruby version
* Install gems using Bundler
* Create local copies of `.env` and `database.yml`
* Create, migrate, and seed the database

### Run it!

1. Run `bin/rake spec` to make sure everything works.
2. Run `bin/rake spec:system` to run system (capybara) tests.
3. Run `bin/rails s` and `bin/sidekiq` to start the app and Sidekiq; alternatively, start both at once with `heroku local`.

## Deployment

Ensure the following environment variables are set in the deployment environment to configure
the environment. Other, application-specific configuration keys can be found in `example.env`.

* `RACK_ENV`
* `RAILS_ENV`
* `REDIS_URL`
* `SECRET_KEY_BASE`
* `SIDEKIQ_WEB_PASSWORD`
* `SIDEKIQ_WEB_USERNAME`

Optionally:

* `HOSTNAME`
* `RAILS_FORCE_SSL`
* `RAILS_LOG_TO_STDOUT`
* `RAILS_MAX_THREADS`
* `RAILS_SERVE_STATIC_FILES`
* `WEB_CONCURRENCY`

[rbenv]:https://github.com/sstephenson/rbenv
[redis]:http://redis.io
[Homebrew]:http://brew.sh

## Browser support

We support the latest 2 versions (stable releases) of major browsers for desktop and mobile. At the time of writing this is:

| Browser       | Desktop     | iOS    | Android |
| ------------- |-------------| -------| --------|
| Chrome        | 76, 75      | 76, 75 | 76, 75  |
| Edge          | 17, 16      | N/A    | 15, 14  |
| Firefox       | 69, 68      | 18, 17 | 68, 67  |
| Safari        | 13, 12      | 12, 11 | N/A     |

You can check the versions covered by our `browserslist` configuration [here](https://browserl.ist/?q=%3E+0.25%25+in+NZ+and+last+2+versions%2C+not+ie+11%2C+not+op_mini+all)
