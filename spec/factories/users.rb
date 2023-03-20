FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "#{Faker::Internet.username}#{n}" }
    email { Faker::Internet.email }
    bio { Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false) }
    password { "password" }
    password_confirmation { "password" }
    confirmed_at { Time.zone.now }

    trait :with_avatar do
      after(:create) do |user|
        image_file = Rails.root.join("spec/fixtures/image.jpeg").open
        image_file_io = { io: image_file, filename: File.basename(image_file) }
        user.avatar.attach(image_file_io)
      end
    end

    trait :moderator do
      moderator { true }
    end

    trait :approved do
      approved { true }
    end

    trait :administrator do
      administrator { true }
    end

    trait :validator do
      validator { true }
    end

    trait :approved do
      approved { true }
    end

    trait :unconfirmed do
      confirmed_at { nil }
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
