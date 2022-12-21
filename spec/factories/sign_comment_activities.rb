FactoryBot.define do
  factory :sign_comment_activity do
    sign_comment
    user
    key { :read }
  end
end
