class UserPresenter < ApplicationPresenter
  presents :user
  delegate_missing_to :user
  delegate :to_param, to: :user

  def avatar
    if user.avatar.attached?
      transform(user.avatar)
    else
      "media/images/avatar.svg"
    end
  end

  private

  def transform(avatar)
    avatar.variant(resize_to_fill: [64, 64])
  end
end
