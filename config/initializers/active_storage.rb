##
# Extend VideoPreviewer with support for extracting a frame from a particular time
require Rails.root.join("lib/active_storage/previewer/video_previewer_ext")

##
# Extend ActiveStorage::DiskService in dev and test to properly verify content types
# with parameters, like text/html;encoding=utf-8
require Rails.root.join("lib/active_storage_ext/app/controllers/disk_controller")
