class LocalPublisher
  THUMBNAIL_SIZES = [
    [1080, 720],
    [640, 480]
  ].freeze

  def publish(blob, _metadata=nil)
    # Local publisher doesn't need to take any action on storage,
    # but should process attachments
    THUMBNAIL_SIZES.each do |size|
      blob.preview(resize_to: size).processed
    end
  end
end
