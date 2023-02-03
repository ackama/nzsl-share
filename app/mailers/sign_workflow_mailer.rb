class SignWorkflowMailer < ApplicationMailer
  def moderation_requested(sign)
    @moderators = User.where(moderator: true)
    @sign = sign

    mail bcc: moderators
  end

  def published(sign)
    @contributor = sign.contributor
    @sign = sign

    mail to: @contributor.email
  end

  def declined(sign)
    @contributor = sign.contributor
    @sign = sign

    mail to: @contributor.email
  end
end
