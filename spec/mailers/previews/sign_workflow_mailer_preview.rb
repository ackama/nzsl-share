# Preview all emails at http://localhost:3000/rails/mailers/sign_workflow_mailer
class SignWorkflowMailerPreview < ActionMailer::Preview
  def moderation_requested
    sign = FactoryBot.build_stubbed(:sign, :submitted)
    SignWorkflowMailer.moderation_requested(sign)
  end

  def published
    sign = FactoryBot.build_stubbed(:sign, :published)
    SignWorkflowMailer.published(sign)
  end

  def declined
    sign = FactoryBot.build_stubbed(:sign, :declined)
    SignWorkflowMailer.declined(sign)
  end
end
