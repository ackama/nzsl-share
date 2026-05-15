class DictionarySignPresenter < ApplicationPresenter
  NZSL_DICTIONARY_HOST = "https://nzsl.nz".freeze
  presents :sign
  delegate_missing_to :sign

  def url
    "#{NZSL_DICTIONARY_HOST}/signs/#{sign.id}"
  end

  def truncated_secondary
    h.truncate(secondary)
  end

  def sign_video_sourceset
    h.content_tag(:source, nil, src: video)
  end

  def sign_video_attributes
    h.video_attributes(class: ["has-video"])
  end
end
