class CollaborationMailer < ApplicationMailer
  def success(collaborator)
    @collaborator = collaborator
    mail(to: @collaborator.email)
  end
end
