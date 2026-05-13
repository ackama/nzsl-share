namespace :video_processing do
  desc "TODO"
  task unstick: :environment do
    stuck_video_age_minutes = ENV.fetch("STUCK_VIDEO_AGE_MINUTES", 1440)
    stuck_signs = Sign.where(created_at: Date.new..stuck_video_age_minutes.minutes.ago).where(processed_videos: false)

    stuck_signs.each do |sign|
      # check here if the blob exists?
      # if not, don't try and requeue
      # Put error in log perhaps?
      # if I test for "video"? maybe thats a test for existence?
      SignPostProcessor.new(sign).process if @sign.last.video.blob.video?
    end
  end
end
