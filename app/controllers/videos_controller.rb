class VideosController < ApplicationController
  skip_before_action :store_user_location!

  def show
    unless representation.exist?
      representation.process_later
      return head(:accepted)
    end

    redirect_to representation.processed
  end

  private

  def blob
    ActiveStorage::Blob.find_signed!(params[:id])
  end

  def preset
    VideoEncodingPreset.new.presetmap[preset_name] ||
      (fail ActionController::RoutingError, "Unknown preset '#{preset_name}'")
  end

  def preset_name
    params[:preset]
  end

  def representation
    @representation ||= CachedVideoTranscoder.new(blob, preset.to_a)
  end
end
