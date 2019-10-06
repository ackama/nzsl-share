FactoryBot.define do
  factory :topic do
    # Returns a 'categorisation: "Grocery, Books, Health & Beauty"
    name { Faker::Commerce.department }
    trait :featured do
      featured_at { Time.zone.now }
    end
  end
end
