FactoryBot.define do
  factory :sign_comment do
    comment     { Faker::Lorem.sentence }
    sign        { FactoryBot.create(:sign) }
    user        { FactoryBot.create(:user) }
    sign_status { sign.status }
  end
end