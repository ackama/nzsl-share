require "open-uri"

class VimeoThumbnailsJob < ApplicationJob
  THUMBNAIL_CONTENT_TYPE = "image/jpeg".freeze
  class ThumbnailsNotReady < StandardError
    def initialize(blob)
      msg = "No thumbnails are ready yet for #{blob.metadata.dig(:vimeo, :link)}"
      super(msg)
    end
  end

  queue_as :vimeo_thumbnail_fetching
  retry_on ThumbnailsNotReady, wait: :exponentially_longer

  def perform(blob)
    # No processing required on non-Vimeo blobs
    return unless blob.metadata[:vimeo]

    # Look up the Vimeo video
    data = vimeo_client.get(
      "/videos/#{blob.metadata.dig(:vimeo, :id)}/pictures",
      fields: "active,sizes.width,sizes.height,sizes.link").data

    # If the video is not active, then we should wait and see if it becomes active
    fail ThumbnailsNotReady, blob unless data.active

    data.sizes.each do |size|
      preview = build_preview(blob, size)
      next if preview.send(:processed?) # Skip any thumbnails that have already been processed

      store_preview(blob, preview, size)
    end
  end

  private

  def vimeo_client
    VimeoClient.new
  end

  def build_preview(blob, size)
    ActiveStorage::Preview.new(blob, resize_to: [size.width, size.height])
  end

  def store_preview(blob, variant, size)
    io = URI.parse(size.link).open
    blob.service.upload(variant.variation.key, io, content_type: THUMBNAIL_CONTENT_TYPE)
  end
end
