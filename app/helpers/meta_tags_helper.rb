# frozen_string_literal: true

module MetaTagsHelper
  def open_graph_title(name=:title)
    content?(name) ? social_media_tag(name, OPENGRAPH, PROPERTY) : nil
  end

  def open_graph_description(name=:description)
    content?(name) ? social_media_tag(name, OPENGRAPH, PROPERTY) : nil
  end

  def open_graph_image(name=:image)
    content?(name) ? social_media_tag(name, OPENGRAPH, PROPERTY) : nil
  end

  def open_graph_image_width(name=:image_width)
    content?(name) ? social_media_tag(name, OPENGRAPH, PROPERTY) : nil
  end

  def open_graph_image_height(name=:image_height)
    content?(name) ? social_media_tag(name, OPENGRAPH, PROPERTY) : nil
  end

  def twitter_card(name=:card)
    social_media_tag(name, TWITTER, NAME, "summary")
  end

  def twitter_title(name=:title)
    content?(name) ? social_media_tag(name, TWITTER, NAME) : nil
  end

  def twitter_description(name=:description)
    content?(name) ? social_media_tag(name, TWITTER, NAME) : nil
  end

  def twitter_image(name=:image)
    content?(name) ? social_media_tag(name, TWITTER, NAME) : nil
  end

  private

  OPENGRAPH = :og
  TWITTER = :twitter
  PROPERTY = :property
  NAME = :name

  def content?(name)
    content_for?(sym_name(name))
  end

  def sym_name(name)
    ("social_media_" + name.to_s).to_sym
  end

  def social_media_tag(name, protocol, attribute, content=nil)
    social_media = content.presence || content_for(sym_name(name))
    content_tag(:meta, nil, "#{attribute}": "#{protocol}:#{name}", content: social_media)
  end
end
