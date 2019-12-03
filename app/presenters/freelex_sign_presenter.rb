class FreelexSignPresenter < ApplicationPresenter
  presents :sign
  delegate_missing_to :sign

  def url
    "#{FREELEX_CONFIG[:public_host]}/signs/#{sign.headword_id}"
  end

  def truncated_secondary
    h.truncate(sign.secondary)
  end

  def video_url
    "#{FREELEX_CONFIG[:asset_host]}#{video_key}"
  end

  def sign_video_sourceset
    # There are also mp4 versions of the videos available, but these are
    # not returned by Freelex.
    sources = [video_url, video_url.gsub(/\.webm/, ".mp4")]
    h.safe_join(sources.map { |src| h.content_tag(:source, nil, src: src) })
  end

  def sign_video_attributes
    h.video_attributes(class: ["has-video"])
  end
end
