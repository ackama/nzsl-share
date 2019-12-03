FactoryBot.define do
  factory :freelex_sign do
    sequence(:headword_id) { |n| n }
    word { Faker::Name.first_name }
    maori        { Faker::Name.last_name        } # until we get some proper data
    secondary    { Faker::Name.middle_name      }
    published_at { Time.zone.now }
  end
end
