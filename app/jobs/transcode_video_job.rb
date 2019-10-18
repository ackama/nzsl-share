class TranscodeVideoJob < ApplicationJob
  queue_as :video_encoding

  # If this job runs and we run into this error, this just means that the blob
  # has already been processed, so we don't need to retry.
  discard_on ActiveRecord::RecordNotUnique

  def perform(blob, ffmpeg_args)
    CachedVideoTranscoder.new(blob, ffmpeg_args).processed
  end
end
