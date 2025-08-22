FactoryBot.define do
  factory :folder do
    user
    title { Faker::Name.name }
    description { Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false) }

    after :create do |folder|
      folder.collaborators << folder.user
    end

    trait :with_35_associated_signs do
      after :build do |folder|
        folder.signs = build_list(:sign, 35, :published)
      end
    end
  end
end
