class ApprovedUserMailer < ApplicationMailer
  def submitted(application)
    @user = application.user
    @nzsl_text_signature = nzsl_text_signature
    mail to: @user.email
  end

  def admin_submitted(application)
    @application = application
    mail to: admins
  end

  def accepted(application)
    @user = application.user
    @nzsl_text_signature = nzsl_text_signature
    mail to: @user.email
  end

  def declined(application)
    @user = application.user
    @nzsl_text_signature = nzsl_text_signature
    mail to: @user.email
  end
end
