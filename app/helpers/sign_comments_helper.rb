module SignCommentsHelper
  def sign_comment_policy(current_user, comment, current_folder_id)
    SignCommentPolicy.new(current_user, comment, current_folder_id: current_folder_id)
  end
end
