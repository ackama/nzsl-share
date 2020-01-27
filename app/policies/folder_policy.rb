class FolderPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    collaborator?
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

  def manage_collaborators?
    collaborator?
  end

  class Scope < Scope
    def resolve
      base = scope.left_outer_joins(:collaborations)
      collaborative = base.where(collaborations: { collaborator_id: user.id })
      owned = base.where(user_id: user.id)
      collaborative.or(owned).distinct.in_order
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
