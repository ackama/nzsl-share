require "active_storage/disk_controller"

class ActiveStorage::DiskController
  private

  ##
  # Fixes a bug where you are trying to upload a file which has a Content Type that includes a charset
  # (eg. text/html; charset=UTF-8).
  # Previously that would trigger a 422 Unprocessable Entity error in ActiveStorage::DiskController#update.
  # content_mime_type strips all parameters from the Content Type which causes the comparison to fail.
  #
  # https://github.com/rails/rails/pull/41269
  def acceptable_content?(token)
    token[:content_type] == request.content_mime_type && token[:content_length] == request.content_length
    media_type = token[:content_type][/^([^,;]*)/]
    media_type == request.content_mime_type && token[:content_length] == request.content_length
  end
end
