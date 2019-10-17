FactoryBot.define do
  factory :sign do
    word { Faker::Name.first_name }
    maori        { Faker::Name.last_name        } # until we get some proper data
    secondary    { Faker::Name.middle_name      }
    video        do
      video_file = File.open(Rails.root.join("spec", "fixtures", "dummy.mp4"))
      { io: video_file, filename: File.basename(video_file) }
    end

    association :topic
    association :contributor, factory: :user

    trait :published do
      published_at { DateTime.now - (rand * 1000) }
    end
  end
end
