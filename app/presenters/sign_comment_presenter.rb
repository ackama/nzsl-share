# frozen_string_literal: true

class SignCommentPresenter < ApplicationPresenter
  presents :sign_comment
  delegate_missing_to :sign_comment

  def friendly_date
    created = sign_comment.created_at

    return h.localize(created, format: "%-d %b %Y") unless created.today?

    "Today at #{h.localize(sign_comment.created_at, format: "%I:%M %p")}"
  end

  def username
    sign_comment.user.username
  end

  def user_comment
    h.simple_format(sign_comment.comment, {}, wrapper_tag: "span")
  end

  def user_avatar
    user = h.present(sign_comment.user)
    user.avatar("avatar avatar--small")
  end
end
