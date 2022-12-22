class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", nil)
  layout "mailer"
  helper :mailers

  def admins
    User.where(administrator: true).map(&:email)
  end

  def moderators
    User.where(moderator: true).map(&:email)
  end
end
