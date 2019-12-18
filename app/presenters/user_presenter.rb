class UserPresenter < ApplicationPresenter
  presents :user
  delegate_missing_to :user
  delegate :to_param, to: :user

  def avatar(classes="")
    h.display_avatar(user, classes)
  end
end
