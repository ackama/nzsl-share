class CollaborationPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    collaborator?
  end

  private

  def collaborator?
    record.folder.collaborators.map(&:id).include? user.id
  end
end
