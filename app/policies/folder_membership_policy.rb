class FolderMembershipPolicy < ApplicationPolicy
  def create?
    owns_folder?
  end

  def destroy?
    owns_folder?
  end

  private

  def owns_folder?
    record.folder.user_id == user.id
  end

  class Scope < Scope
    def resolve
      scope.includes(:folder).where(folders: { user_id: user.id })
    end
  end
end
