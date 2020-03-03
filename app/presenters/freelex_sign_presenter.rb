class FreelexSignPresenter < ApplicationPresenter
  presents :sign
  delegate_missing_to :sign

  def url
    "#{FREELEX_CONFIG[:public_host]}/signs/#{sign.headword_id}"
  end

  def truncated_secondary
    h.truncate(sign.secondary)
  end

  def freelex_asset_video_url(key)
    "#{FREELEX_CONFIG[:asset_host]}#{key}"
  end

  def sign_video_sourceset
    # There are also mp4 versions of the videos available - these are
    # also returned by Freelex.
    h.safe_join(video_key.map { |src| h.content_tag(:source, nil, src: freelex_asset_video_url(src)) })
  end

  def sign_video_attributes
    h.video_attributes(class: ["has-video"])
  end
end
