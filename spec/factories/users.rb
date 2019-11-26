FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "#{Faker::Internet.username}#{n}" }
    email { Faker::Internet.email }
    bio { Faker::Lorem.paragraph_by_chars(256, false) }
    password { "password" }
    password_confirmation { "password" }
    confirmed_at { Time.zone.now }

    trait :moderator do
      moderator { true }
    end

    trait :approved do
      approved { true }
    end

    trait :administrator do
      administrator { true }
    end

    trait :approved do
      approved { true }
    end

    trait :with_demographics do
      callback(:after_build, :after_stub) do |user|
        user.build_demographic(
          FactoryBot.attributes_for(:demographic)
        )
      end
    end
  end
end
