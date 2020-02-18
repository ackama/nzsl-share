class CollaborationMailer < ApplicationMailer
  def success(collaboration)
    @collaboration = collaboration
    @collaborator = @collaboration.collaborator
    @nzsl_text_signature = nzsl_text_signature
    mail to: @collaborator.email
  end
end
