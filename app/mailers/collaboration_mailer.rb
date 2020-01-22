class CollaborationMailer < ApplicationMailer
  def success(collaboration)
    @folder = Folder.find(collaboration.folder_id)
    @collaborator = User.find(collaboration.collaborator_id)
    mail to: @collaborator.email
  end
end
