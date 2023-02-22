##
# Extend VideoPreviewer with support for extracting a frame from a particular time
require Rails.root.join("lib/active_storage/previewer/video_previewer_ext")

##
# Use video_preview_arguments from Rails 6.1, _without_ the video filter added in Rails 7:
# -vf 'select=eq(n\\,0)+eq(key\\,1)+gt(scene\\,0.015),loop=loop=-1:size=2,trim=start_frame=1' -frames:v 1 -f image2
#
# We seek to a duration when generating posters for video files proportional to
# the video length using the -ss option, which doesn't work the way we expect
# with the -vf option (since the -vf option has already 'seeked' to a time it
# thinks is relevant)
Rails.application.config.active_storage.video_preview_arguments = "-y -vframes 1 -f image2"

##
# Extend ActiveStorage::DiskService in dev and test to properly verify content types
# with parameters, like text/html;encoding=utf-8
Rails.application.config.to_prepare do
  require Rails.root.join("lib/active_storage_ext/app/controllers/disk_controller")
end
