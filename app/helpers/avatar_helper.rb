module AvatarHelper
  def transform(avatar)
    avatar.variant(resize_to_fill: [64, 64]).processed.service_url
  end
end
