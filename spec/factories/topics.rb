FactoryBot.define do
  factory :topic do
    sequence(:name) { |n| "Topic ##{n}" }
    trait :featured do
      featured_at { Time.zone.now }
    end

    trait :with_associated_signs do
      after :build do |topic|
        topic.signs = build_list(:sign, 5)
      end
    end
  end
end
