FactoryBot.define do
  factory :sign do
    word { Faker::Name.first_name }
    maori        { Faker::Name.last_name        } # until we get some proper data
    secondary    { Faker::Name.middle_name      }
    contributor_id { FactoryBot.create(:user) }
    video        do
      video_file = File.open(Rails.root.join("spec", "fixtures", "dummy.mp4"))
      { io: video_file, filename: File.basename(video_file) }
    end

    association :topic
    association :contributor, factory: :user

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
      status { "personal" }
    end

    trait :submitted do
      status { "submitted" }
      submitted_at { Time.zone.now - 5 }
      conditions_accepted { true }
    end

    trait :published do
      status { "published" }
      conditions_accepted { true }
      published_at { Time.zone.now - 5 }
    end

    trait :archived do
      status { "archived" }
      conditions_accepted { true }
    end

    trait :declined do
      status { "declined" }
      declined_at { Time.zone.now - 5 }
      conditions_accepted { true }
    end

    trait :unpublish_requested do
      status { "unpublish_requested" }
      requested_unpublish_at { Time.zone.now - 5 }
      conditions_accepted { true }
    end

    trait :with_usage_examples do
      after(:create) do |sign|
        video_file = File.open(Rails.root.join("spec", "fixtures", "dummy.mp4"))
        video_file_io = { io: video_file, filename: File.basename(video_file) }

        sign.usage_examples.attach(video_file_io)
      end
    end

    trait :with_illustrations do
      after(:create) do |sign|
        video_file = File.open(Rails.root.join("spec", "fixtures", "image.jpeg"))
        video_file_io = { io: video_file, filename: File.basename(video_file) }

        sign.illustrations.attach(video_file_io)
      end
    end
  end
end
