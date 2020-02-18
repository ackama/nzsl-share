module SignCommentsHelper
  def allow_new_comment(current_user, comment, current_folder_id)
    SignCommentPolicy.new(current_user, comment, current_folder_id: current_folder_id).create?
  end
end
