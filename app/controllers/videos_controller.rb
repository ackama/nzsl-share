class VideosController < ApplicationController
  skip_before_action :store_user_location!

  def show
    video = if representation.exist?
              representation.processed
            elsif ENV.fetch("ENABLE_ORIGINAL_VIDEO_FALLBACK", false) == true
              representation.process_later
              return head(:accepted)
            else
              blob.url
            end

    redirect_to video, allow_other_host: true
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
