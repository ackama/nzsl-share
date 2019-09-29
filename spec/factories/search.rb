FactoryBot.define do
  factory :search do
    word      { Faker::Name.first_name }
    published { %w[0 1].sample }
  end
end
