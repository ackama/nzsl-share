FactoryBot.define do
  factory :comment_report do
    user
    association :comment, factory: :sign_comment
    association :resolved_by, factory: :user
  end
end
