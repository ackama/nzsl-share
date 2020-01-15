class CollaborationMailer < ApplicationMailer
  def success(collaborator, folder)
    @folder = folder
    @collaborator = collaborator
    mail to: @collaborator.email
  end
end
