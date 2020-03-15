# frozen_string_literal: true

class SignCommentPresenter < ApplicationPresenter
  presents :sign_comment
  delegate_missing_to :sign_comment

  def friendly_date
    created = sign_comment.created_at

    return h.localize(created, format: "%-d %b %I:%M %p %Y") unless created.today?

    "Today at #{h.localize(created, format: "%I:%M %p")}"
  end

  def username
    sign_comment.user.username
  end

  def user_comment
    convert_urls(sign_comment.comment)
  end

  def video_description
    convert_urls(sign_comment.video_description)
  end

  def user_avatar
    user = h.present(sign_comment.user)
    user.avatar("avatar avatar--small")
  end

  private

  def convert_urls(comment="")
    h.simple_format(Sanitizer.sanitize(comment).gsub(URI::DEFAULT_PARSER.make_regexp) do |url|
      u = Sanitizer.sanitize_url(url)
      "<a class='sign-comments__comment__username--link' target='_blank' rel='noopener noreferrer' href=#{u}>#{u}</a>"
    end, {}, wrapper_tag: "span", sanitize: false)
  end
end
