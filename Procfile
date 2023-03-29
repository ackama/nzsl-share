web:     bundle exec puma -C config/puma.rb
worker:  bundle exec sidekiq -c 5 -C config/sidekiq.yml
release: bundle exec rake dictionary:update && bundle exec rake db:migrate db:seed
