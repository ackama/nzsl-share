class ApprovedUserMailer < ApplicationMailer
  def pending(user)
    @user = user
    mail to: user.email
  end

  def approved(user)
  end

  def declined(user)
  end
end
