FactoryBot.define do
  factory :sign do
    english      { Faker::Name.first_name       }
    maori        { Faker::Name.last_name        } # until we get some proper data
    secondary    { Faker::Name.middle_name      }
    association :topic
    association :contributor, factory: :user

    trait :published do
      published_at { DateTime.now - (rand * 1000) }
    end

    trait :with_contributor do
      after :build do |sign|
        sign.contributor = FactoryBot.create(:user)
      end
    end
  end
end
