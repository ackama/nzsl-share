class TranscodeVideoJob < ApplicationJob
  queue_as :video_encoding

  def perform(blob, ffmpeg_args)
    CachedVideoTranscoder.new(blob, ffmpeg_args).processed
  end
end
