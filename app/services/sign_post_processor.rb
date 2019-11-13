class SignPostProcessor < SignAttachmentPostProcessor
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

  def initialize(sign, presets=nil)
    @sign = sign
    super(@sign.video.blob, presets)
  end

  def process
    sign.update!(processed_videos: false, processed_thumbnails: false)

    [
      batch("Generate thumbnails", ThumbnailCallback, sign_id: sign.id) { thumbnail_processes },
      batch("Transcode videos", VideoCallback, sign_id: sign.id) { video_processes }
    ]
  end

  private

  attr_reader :sign
end
