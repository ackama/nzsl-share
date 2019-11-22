class ApprovedUserMailer < ApplicationMailer
  def submitted(user)
    @user = user
    mail to: user.email
  end

  def accepted(user)
  end

  def declined(user)
  end
end
