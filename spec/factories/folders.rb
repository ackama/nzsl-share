FactoryBot.define do
  factory :folder do
    user
    title { Faker::Name.name }
    description { Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false) }

    after :create do |folder|
      folder.collaborators << folder.user
    end
  end
end
