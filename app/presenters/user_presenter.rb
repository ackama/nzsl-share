class UserPresenter < ApplicationPresenter
  presents :user
  delegate_missing_to :user
  delegate :to_param, to: :user

  def avatar(classes="")
    if user.avatar.attached?
      h.image_tag(transform(user.avatar), class: classes)
    else
      h.inline_svg_pack_tag("media/images/avatar.svg", title: "Avatar", aria: true, class: classes)
    end
  end

  private

  def transform(avatar)
    avatar.variant(resize_to_fill: [64, 64])
  end
end
