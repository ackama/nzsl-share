FactoryBot.define do
  factory :demographic do
    user
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    deaf { [true, false].sample }
    nzsl_first_language { [true, false].sample }
    age_bracket { Demographic.age_brackets.sample }
    location { Faker::Address.city }
    gender { Demographic.genders.sample }
    ethnicity { Demographic.ethnicities.sample }
    language_roles { Demographic.language_roles.sample(3) }
    subject_expertise { Faker::Job.key_skill }
  end
end
