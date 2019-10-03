FactoryBot.define do
  factory :sign do
    english   { Faker::Name.first_name   }
    maori     { Faker::Name.last_name    } # until we get some proper data
    secondary { Faker::Name.middle_name  }
    association :topic
  end
end
