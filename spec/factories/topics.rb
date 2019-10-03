FactoryBot.define do
  factory :topic do
    name { Faker::Lorem.word }

    trait :featured do
      featured_at { Time.zone.now }
    end
  end
end
