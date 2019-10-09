class FolderMembershipPolicy < ApplicationPolicy
  def create?
    record.folder.user_id == user.id
  end

  def destroy?
    record.folder.user_id == user.id
  end

  class Scope < Scope
    def resolve
      scope.includes(:folder).where(folders: { user_id: user.id })
    end
  end
end
