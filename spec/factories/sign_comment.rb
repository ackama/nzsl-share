FactoryBot.define do
  factory :sign_comment do
    comment     { Faker::Lorem.sentence }
    sign        { FactoryBot.create(:sign) }
    user        { FactoryBot.create(:user) }
    sign_status { sign.status }
    trait :with_folder do
      folder
    end

    trait :video do
      video        do
        video_file = Rails.root.join("spec/fixtures/dummy.mp4").open
        { io: video_file, filename: File.basename(video_file) }
      end
    end
  end
end
