class FolderPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    owns_record? || collaborator?
  end

  def create?
    true
  end

  def new?
    create?
  end

  def update?
    owns_record? || collaborator?
  end

  def edit?
    update?
  end

  def destroy?
    owns_record? && record.user.folders_count > 1
  end

  def share?
    owns_record?
  end

  class Scope < Scope
    def resolve
      folder_ids = Folder.where(user: user).pluck(:id)
      collab_folder_ids = Folder.joins(:collaborations).where(collaborations: { collaborator_id: user.id }).pluck(:id)
      all_folder_ids = folder_ids + collab_folder_ids
      scope.where(id: all_folder_ids).distinct.in_order
    end
  end

  private

  def owns_record?
    record.user == user
  end

  def collaborator?
    record.collaborators.map(&:id).include? user.id
  end
end
