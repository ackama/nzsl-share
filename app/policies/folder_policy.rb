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
    owns_record? || collaborator?
  end

  class Scope < Scope
    def resolve
      scope.joins(:collaborations).where(collaborations: { collaborator_id: user.id })
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
