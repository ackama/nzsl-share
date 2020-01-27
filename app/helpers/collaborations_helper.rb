module CollaborationsHelper
  def find_collaboration(collaborator_id, folder_id)
    Collaboration.find_by(collaborator_id: collaborator_id, folder_id: folder_id)
  end
end
