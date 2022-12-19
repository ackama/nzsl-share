class SignWorkflowMailer < ApplicationMailer
  def moderation_requested(sign)
    @moderators = User.where(moderator: true)
    @sign = sign

    mail bcc: moderators
  end
end
