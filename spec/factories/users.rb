FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "#{Faker::Internet.username}#{n}" }
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    confirmed_at { Time.zone.now }

    trait :moderator do
      moderator { true }
    end
  end
end
