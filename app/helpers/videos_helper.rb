module VideosHelper
  def video_source_tag(video, preset)
    content_tag(:source, nil, src: video_path(id: video.signed_id, preset: preset))
  end

  def video_sourceset(video, presets=nil)
    presets ||= %w[1080p 720p 360p]
    safe_join(presets.map { |preset| video_source_tag(video, preset) })
  end

  def video_attributes(extras={})
    class_list = ["video"]

    {
      class: (class_list + (Array(extras.delete(:class)) || [])).join(" "),
      controls: true,
      controlslist: "nodownload",
      preload: "none",
      muted: true,
      **extras
    }
  end
end
