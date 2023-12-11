FactoryBot.define do
  factory :sign do
    word { Faker::Name.first_name }
    maori        { Faker::Name.last_name        } # until we get some proper data
    secondary    { Faker::Name.middle_name      }
    contributor_id { FactoryBot.create(:user) }
    video        do
      video_file = Rails.root.join("spec/fixtures/dummy.mp4").open
      { io: video_file, filename: File.basename(video_file) }
    end

    association :contributor, factory: :user

    after :create do |sign|
      sign.topics << FactoryBot.create(:topic)
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
        video_file = Rails.root.join("spec/fixtures/dummy.mp4").open
        video_file_io = { io: video_file, filename: File.basename(video_file) }

        sign.usage_examples.attach(video_file_io)
      end
    end

    trait :with_illustrations do
      after(:create) do |sign|
        video_file = Rails.root.join("spec/fixtures/image.jpeg").open
        video_file_io = { io: video_file, filename: File.basename(video_file) }

        sign.illustrations.attach(video_file_io)
      end
    end

    trait :with_additional_info do
      description { Faker::Lorem.sentence }
      notes { Faker::Lorem.paragraph }
    end

    trait :with_sign_activities do
      activities { FactoryBot.create_list(:sign_activity, 5) }
    end

    trait :with_sign_comments do
      sign_comments { FactoryBot.create_list(:sign_comment, 2) }
    end
  end
end
