# frozen_string_literal: true

module SignCommentsHelper
  def video_form(sign)
    sign_comment = fetch_sign_comment(sign)
    if sign_comment.blank?
      { model: SignComment.new, url: video_sign_comment_path(sign, 0), method: :post }
    else
      { model: sign_comment, url: sign_comment_path(sign, sign_comment), method: :patch }
    end
  end

  def video_file_field(sign)
    sign_comment = fetch_sign_comment(sign)
    if sign_comment.blank?
      { class: "show-for-sr js-sign-comment-submit-video", accept: "video/mp4" }
    else
      { class: "show-for-sr", accept: "video/mp4", disabled: true }
    end
  end

  def fetch_sign_comment(sign)
    sign.sign_comments.where(display: false).order(created_at: :asc).first # race conditions ...
  end

  def sign_comment_count(sign)
    sign.sign_comments.where(display: true).count
  end

  def http_patch?(form)
    form[:method] == :patch
  end

  def http_post?(form)
    form[:method] == :post
  end
end
