FactoryBot.define do
  factory :folder do
    user
    title { Faker::Name.name }
    description { Faker::Lorem.paragraph_by_chars(256, false) }
  end
end
