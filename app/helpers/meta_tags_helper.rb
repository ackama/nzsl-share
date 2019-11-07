# frozen_string_literal: true

module MetaTagsHelper
  def facebook_title(name)
    content?(name) ? facebook_tag(name) : nil
  end

  def facebook_description(name)
    content?(name) ? facebook_tag(name) : nil
  end

  def facebook_image(name)
    content?(name) ? facebook_tag(name) : nil
  end

  def twitter_title(name)
    content?(name) ? twitter_tag(name) : nil
  end

  def twitter_description(name)
    content?(name) ? twitter_tag(name) : nil
  end

  def twitter_image(name)
    content?(name) ? twitter_tag(name) : nil
  end

  private

  def content?(name)
    content_for?(content(name))
  end

  def content(name)
    ("social_media_" + name).to_sym
  end

  def facebook_tag(name)
    content_tag(:meta, nil, property: "og:#{name}", content: content_for(content(name)))
  end

  def twitter_tag(name)
    content_tag(:meta, nil, name: "twitter:#{name}", content: content_for(content(name)))
  end
end
