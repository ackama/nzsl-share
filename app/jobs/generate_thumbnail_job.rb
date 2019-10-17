class GenerateThumbnailJob < ApplicationJob
  queue_as :thumbnail_generation

  def perform(blob, preview_args)
    blob.preview(preview_args).processed
  end
end
