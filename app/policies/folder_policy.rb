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
    collaborator?
  end

  def edit?
    update?
  end

  def destroy?
    owns_record? && collaborator? && record.user.folders_count > 1
  end

  def share?
    owns_record? || collaborator?
  end

  def manage_collaborators?
    collaborator?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user

      base = scope.left_outer_joins(:collaborations)
      collaborative = base.where(collaborations: { collaborator_id: user.id })
      collaborative.distinct.in_order
    end
  end

  private

  def owns_record?
    record.user == user
  end

  def collaborator?
    return unless user

    record.collaborators.map(&:id).include? user.id
  end
end
