class VideosController < ApplicationController
  PRESET_MAP = {
    "1080p" => VideoEncodingPreset.default.muted.scale_1080,
    "720p" => VideoEncodingPreset.default.muted.scale_720,
    "360p" => VideoEncodingPreset.default.muted.scale_360
  }.freeze

  def show
    unless representation.exist?
      representation.process_later
      return head(:accepted)
    end

    redirect_to representation.processed
  end

  def blob
    ActiveStorage::Blob.find_signed(params[:id])
  end

  def preset
    PRESET_MAP[preset_name] || (fail ActionController::RoutingError, "Unknown preset '#{preset_name}'")
  end

  def preset_name
    params[:preset]
  end

  def representation
    @representation ||= CachedVideoTranscoder.new(blob, preset.to_a)
  end
end
