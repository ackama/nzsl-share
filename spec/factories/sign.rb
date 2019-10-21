FactoryBot.define do
  factory :sign do
    english      { Faker::Name.first_name       }
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

    trait :unprocessed do
      processed_videos { false }
      processed_thumbnails { false }
    end

    trait :processed_thumbnails do
      processed_thumbnails { true }
    end

    trait :processed_videos do
      processed_videos { true }
    end

    trait :processed do
      processed_videos { true }
      processed_thumbnails { true }
    end
  end
end
