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

    trait :personal do
      aasm_state { "personal" }
    end
    trait :submitted do
      aasm_state { "submitted" }
      submitted_at { Time.zone.now - 5 }
    end
    trait :published do
      aasm_state { "published" }
      published_at { Time.zone.now - 5 }
    end
    trait :declined do
      aasm_state { "declined" }
      declined_at { Time.zone.now - 5 }
    end
    trait :deletion_requested do
      aasm_state { "deletion_requested" }
      deletion_requsted_at { Time.zone.now - 5 }
    end
  end
end
