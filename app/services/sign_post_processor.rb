class SignPostProcessor
  class ThumbnailCallback
    def on_success(_status, options)
      sign = Sign.find(options.fetch("sign_id"))
      sign.update!(processed_thumbnails: true)
    end
  end

  class VideoCallback
    def on_success(_status, options)
      sign = Sign.find(options.fetch("sign_id"))
      sign.update!(processed_videos: true)
    end
  end

  def initialize(sign, presets=default_presets)
    @sign = sign
    @presets = presets
  end

  def process
    sign.update!(processed_videos: false, processed_thumbnails: false)

    [
      batch("Generate thumbnails", ThumbnailCallback) { thumbnail_processes },
      batch("Transcode videos", VideoCallback) { video_processes }
    ]
  end

  private

  def video_processes
    @presets[:video].each { |preset| TranscodeVideoJob.perform_unique_later(sign.video.blob, preset.to_a) }
  end

  def thumbnail_processes
    @presets[:thumbnail].each { |preset| GenerateThumbnailJob.perform_later(sign.video.blob, preset.to_h) }
  end

  def batch(description, callback_handler, &block)
    batch = new_batch
    batch.description = "Post processing: #{description} for Sign ##{sign.id}"

    # We intentionally don't monitor completion, since that can be triggered
    # for incomplete runs. Instead, we just listen for success and allow failed
    # batches to run through the failed/retry/dead Sidekiq workflow.
    batch.on(:success, callback_handler, sign_id: sign.id)

    batch.jobs(&block)
    Rails.logger.info "Started batch: #{batch.bid} - #{batch.description}"

    batch
  end

  def new_batch
    Sidekiq::Batch.new
  end

  def default_presets
    {
      video: [
        VideoEncodingPreset.default.scale_1080.muted,
        VideoEncodingPreset.default.scale_720.muted,
        VideoEncodingPreset.default.scale_360.muted
      ],
      thumbnail: [
        ThumbnailPreset.default.scale_1080,
        ThumbnailPreset.default.scale_720,
        ThumbnailPreset.default.scale_360
      ]
    }
  end

  attr_reader :sign
end
