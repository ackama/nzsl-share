require "active_storage/previewer/video_previewer"

##
# Reopens class to add support for extracting a frame at a specific location, rather than
# from the first frame.
ActiveStorage::Previewer::VideoPreviewer.class_eval do
  private

  def draw_relevant_frame_from(file, &)
    draw(self.class.ffmpeg_path, "-i", file.path, *video_preview_arguments_with_frame_time, "-", &)
  end

  def video_preview_arguments_with_frame_time(proportion: 0.25)
    # Ensures that the blob has been analysed, otherwise there will be no duration and
    # it will default to the start of the video
    blob.analyze

    Shellwords.split(ActiveStorage.video_preview_arguments + " -ss #{blob.metadata.fetch(:duration, 0) * proportion}")
  end
end
