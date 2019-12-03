# frozen_string_literal: true

module MetaTagsHelper
  def og_title
    property = "og:title"
    content = content_for(:og_title) || "NZSL Share"

    og_meta_tag(property, content)
  end

  def og_description
    property = "og:description"
    content = content_for(:og_description) || "community space for NZSL signs posted by the New Zealand Deaf Community"

    og_meta_tag(property, content)
  end

  def og_url
    property = "og:url"
    content = content_for(:og_url) || root_path

    og_meta_tag(property, content)
  end

  def og_image
    property = "og:image"
    content = content_for(:og_image) || ""

    og_meta_tag(property, content)
  end

  private

  def og_meta_tag(property, content)
    content_tag(:meta, nil, "property": property, content: content)
  end
end
