class CollaborationMailer < ApplicationMailer
  def success(collaborator)
    @collaborator = collaborator
    mail(to: @collaborator.email, subject: "You have been added as a collaborator")
  end
end
