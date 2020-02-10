# frozen_string_literal: true

class SignCommentPresenter < ApplicationPresenter
  presents :sign_comment
  delegate_missing_to :sign_comment

  def friendly_date
    created = sign_comment.created_at

    return h.localize(created, format: "%-d %b %Y") unless created.today?

    "Today at #{h.localize(created, format: "%I:%M %p")}"
  end

  def username
    sign_comment.user.username
  end

  def user_comment
    comment_with_href(sign_comment.comment)
  end

  def video_description
    comment_with_href(sign_comment.video.blob.metadata[:description])
  end

  def user_avatar
    user = h.present(sign_comment.user)
    user.avatar("avatar avatar--small")
  end

  private

  def comment_with_href(comment="")
    h.simple_format(comment.gsub(URI::DEFAULT_PARSER.make_regexp) do |u|
      "<a class='sign-comments__comment__username--link' href=#{u}>#{u}</a>"
    end, {}, wrapper_tag: "span")
  end
end
