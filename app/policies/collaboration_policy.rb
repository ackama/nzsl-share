class CollaborationPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    collaborator?
  end

  private

  def folder
    Folder.find(record.folder_id)
  end

  def collaborator?
    folder.collaborators.map(&:id).include? user.id
  end
end
