class CollaborationMailer < ApplicationMailer
  helper :mailers

  def success(collaboration)
    @collaboration = collaboration
    @collaborator = @collaboration.collaborator
    mail to: @collaborator.email
  end
end
