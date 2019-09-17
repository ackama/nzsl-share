FactoryBot.define do
  factory :sign do
    english { FFaker::Food.fruit }
    maori   { FFaker::Internet.email } # until we get some proper data
  end
end
