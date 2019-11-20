FactoryBot.define do
  factory :sign_activity do
    key { [SignActivity::ACTIVITY_AGREE, SignActivity::ACTIVITY_DISAGREE].sample }
    user
    sign
  end
end
