# frozen_string_literal: true

require "./db/data/topics"

namespace :topics do
  desc "Remove existing topics and add default topics"
  task seed: :environment do
    Topic.transaction do
      Topic.destroy_all
      Database::Data::Topics::FEATURED.each { |topic| Topic.create(name: topic, featured_at: DateTime.now) }
      Database::Data::Topics::NON_FEATURED.each { |topic| Topic.create(name: topic) }
      puts("Done.")
    end
  end
end
