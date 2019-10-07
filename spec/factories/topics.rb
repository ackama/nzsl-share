FactoryBot.define do
  factory :topic do
    sequence(:name) { |n| "Topic ##{n}" }
    trait :featured do
      featured_at { Time.zone.now }
    end
  end
end
