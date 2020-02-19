class ApplicationMailer < ActionMailer::Base
  default from: ENV["MAIL_FROM"]
  layout "mailer"

  def admins
    User.where(administrator: true).map(&:email)
  end
end
