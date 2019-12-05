module AvatarHelper
  def transform(avatar)
    avatar.variant(resize_to_fill: [64, 64])
  end

  def display_avatar(user, classes="")
    if user.avatar.attached?
      image_tag(transform(user.avatar), class: classes)
    else
      inline_svg("media/images/avatar.svg", title: "Avatar", aria: true, class: classes)
    end
  end
end
