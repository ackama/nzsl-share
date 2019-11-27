FactoryBot.define do
  factory :approved_user_application do
    user
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    deaf { [true, false].sample }
    nzsl_first_language { [true, false].sample }
    age_bracket { Demographics.age_brackets.sample }
    location { Faker::Address.city }
    gender { Demographics.genders.sample }
    ethnicity { Demographics.ethnicities.sample }
    language_roles { Demographics.language_roles.sample(3) }
    subject_expertise { Faker::Job.key_skill }

    trait :accepted do
      status { :accepted }
    end

    trait :declined do
      status { :declined }
    end
  end
end
