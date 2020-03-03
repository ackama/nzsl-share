FactoryBot.define do
  factory :collaboration do
    folder
    association :collaborator, factory: :user
  end
end
