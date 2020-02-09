FactoryBot.define do
  factory :comment_report do
    user
    association :comment, factory: :sign_comment
  end
end
