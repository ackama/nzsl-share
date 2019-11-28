# frozen_string_literal: true

require "./db/data/topics"

namespace :topics do
  desc "Remove existing topics and add default topics"
  task seed: :environment do
    Topic.transaction do
      remove_topics
      Database::Data::Topics::FEATURED.each { |topic| Topic.create(name: topic, featured_at: DateTime.now) }
      Database::Data::Topics::NON_FEATURED.each { |topic| Topic.create(name: topic) }
    end
  end

  private

  def remove_topics
    ActiveRecord::Base.connection.execute("UPDATE signs SET topic_id=NULL WHERE topic_id IS NOT NULL")
    ActiveRecord::Base.connection.execute("DELETE FROM topics")
  end
end
