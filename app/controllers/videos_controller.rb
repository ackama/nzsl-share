class VideosController < ApplicationController
  skip_before_action :store_user_location!

  def show
    video_location = if representation.exist?
                       representation.processed
                     elsif Rails.application.config.enable_original_fallback_video
                       blob.url
                     else
                       representation.process_later
                       return head(:accepted)
                     end

    redirect_to video_location, allow_other_host: true
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
