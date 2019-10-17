class SignPostProcessor
  class Callbacks
    def on_complete(status, options)
      sign = Sign.find(options.fetch(:sign_id))
      status = status.failures.zero? ? "complete" : "failed"
      sign.video.update!(metadata: sign.video.metadata.merge(post_processing_status: status))
    end
  end

  def initialize(sign, presets=default_presets)
    @sign = sign
    @presets = presets
  end

  def process
    update_status

    batch do
      video_processes
      thumbnail_processes
    end
  end

  private

  def video_processes
    @presets[:video].each { |preset| EncodeVideoJob.perform_later(sign.video.blob, preset.to_a) }
  end

  def thumbnail_processes
    @presets[:thumbnail].each { |preset| GenerateThumbnailJob.perform_later(sign.video.blob, preset.to_h) }
  end

  def update_status
    sign.video.update!(metadata: sign.video.metadata.merge(post_processing_status: "incomplete"))
  end

  def batch(&block)
    batch = Sidekiq::Batch.new
    batch.description = "Post processing for Sign ##{sign.id}"
    batch.on(:complete, SignPostProcessor::Callbacks, sign_id: sign.id)
    batch.jobs(&block)
    Rails.logger.info "Started batch: #{batch.bid} - #{batch.description}"
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
