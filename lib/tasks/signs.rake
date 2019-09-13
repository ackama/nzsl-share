# frozen_string_literal: true

namespace :developers do
  namespace :create do
    desc "The developers need test data so lets create some!"
    task titles: :environment do
      return unless development?

      require "ffaker"
      truncate_table

      500.times do
        Sign.create(english: FFaker::Food.fruit)
      end
    end
  end

  namespace :delete do
    desc "delete the test data and reset the identity key"
    task titles: :environment do
      return unless development?

      truncate_table
    end
  end

  private

  def truncate_table
    ActiveRecord::Base.connection.execute("TRUNCATE #{Sign.table_name} RESTART IDENTITY")
  end

  def development?
    Rails.env.development?
  end
end
