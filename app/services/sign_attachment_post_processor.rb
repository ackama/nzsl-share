class SignAttachmentPostProcessor
  include VideoEncodingHelper

  def initialize(blob, presets=nil)
    @blob = blob
    @presets = presets || default_presets
  end

  def process
    [
      batch("Generate thumbnails") { thumbnail_processes },
      (@blob.video? ? batch("Transcode videos") { video_processes } : nil)
    ]
  end

  private

  def video_processes
    @presets[:video].each { |preset| TranscodeVideoJob.perform_unique_later(@blob, preset.to_a) }
  end

  def thumbnail_processes
    @presets[:thumbnail].each { |preset| GenerateThumbnailJob.perform_later(@blob, preset.to_h) }
  end

  def batch(description, callback_handler=nil, callback_data={}, &block)
    batch = new_batch
    batch.description = "Post processing: #{description} for Blob ##{@blob.id}"

    # We intentionally don't monitor completion, since that can be triggered
    # for incomplete runs. Instead, we just listen for success and allow failed
    # batches to run through the failed/retry/dead Sidekiq workflow.
    batch.on(:success, callback_handler, callback_data) if callback_handler

    batch.jobs(&block)
    Rails.logger.info "Started batch: #{batch.bid} - #{batch.description}"

    batch
  end

  def new_batch
    Sidekiq::Batch.new
  end

  def default_presets
    {
      video: PRESET_MAP.values,
      thumbnail: [
        ThumbnailPreset.default.scale_1080,
        ThumbnailPreset.default.scale_720,
        ThumbnailPreset.default.scale_360
      ]
    }
  end
end
