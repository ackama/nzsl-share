namespace :video_processing do
  desc "Check for signs which should have been processed by now, emitting errors or reenqueueing where appropriate."
  task unstick: :environment do
    # default 24 hours
    stuck_video_age_minutes = ENV.fetch("STUCK_VIDEO_AGE_MINUTES", 1440)
    stuck_signs = Sign.where(created_at: Date.new..stuck_video_age_minutes.minutes.ago).where(processed_videos: false)
    blob_service = ActiveStorage::Blob.service

    stuck_signs.each do |sign|
      if sign.video.nil?
        Rails.logger.error "Missing video for sign '#{sign.word}' id '#{sign.id}'"
        next
      end

      if sign.video.blob.nil?
        Rails.logger.error "Missing video blob record for sign '#{sign.word}' id '#{sign.id}'"
        next
      end

      video_description = " 'sign: #{sign.word}', id: '#{sign.id}', blob key: #{sign.video.blob.key}"

      unless blob_service.exist? sign.video.blob.key
        Rails.logger.error "Missing video blob in ActiveStorage for #{video_description}"
        next
      end

      SignPostProcessor.new(sign).process
      Rails.logger.info "Enqueued processing for #{video_description}"
    end
  end
end
