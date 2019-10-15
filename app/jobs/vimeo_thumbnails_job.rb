require "open-uri"

class VimeoThumbnailsJob < ApplicationJob
  THUMBNAIL_CONTENT_TYPE = "image/jpeg".freeze
  class ThumbnailsNotReady < StandardError
    def initialize(attachment)
      msg = "No thumbnails are ready yet for #{attachment.metadata.dig(:vimeo, :link)}"
      super(msg)
    end
  end

  queue_as :vimeo_thumbnail_fetching
  retry_on ThumbnailsNotReady, wait: :exponentially_longer

  def perform(attachment)
    # No processing required on non-Vimeo attachments
    return unless attachment.metadata[:vimeo]

    # Look up the Vimeo video
    data = vimeo_client.get(
      "/videos/#{attachment.metadata.dig(:vimeo, :id)}/pictures",
      fields: "active,sizes.width,sizes.height,sizes.link").data

    # If the video is not active, then we should wait and see if it becomes active
    fail ThumbnailsNotReady, attachment unless data.active

    data.sizes.each do |size|
      variant = build_variant(attachment, size)
      next if variant.send(:processed?) # Skip any thumbnails that have already been processed

      store_variant(attachment, variant, size)
    end
  end

  private

  def vimeo_client
    VimeoClient.new
  end

  def build_variant(attachment, size)
    ActiveStorage::Variant.new(attachment, resize_to: [size.width, size.height])
  end

  def store_variant(attachment, variant, size)
    io = URI.parse(size.link).open
    attachment.service.upload(variant.key, io, content_type: THUMBNAIL_CONTENT_TYPE)
  end
end
