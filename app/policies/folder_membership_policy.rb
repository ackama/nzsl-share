class FolderMembershipPolicy < ApplicationPolicy
  def create?
    owns_folder? || collaborator?
  end

  def destroy?
    owns_folder? || collaborator?
  end

  class Scope < Scope
    def resolve
      folder_ids = Folder.where(user: user).pluck(:id)
      collab_folder_ids = Folder.joins(:collaborations).where(collaborations: { collaborator_id: user.id }).pluck(:id)
      all_folder_ids = folder_ids + collab_folder_ids
      scope.where(id: all_folder_ids).distinct
    end
  end

  private

  def owns_folder?
    record.folder.user_id == user.id
  end

  def collaborator?
    record.folder.collaborators.map(&:id).include? user.id
  end
end
