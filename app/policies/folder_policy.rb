class FolderPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    owns_record?
  end

  def create?
    true
  end

  def new?
    create?
  end

  def update?
    owns_record?
  end

  def edit?
    update?
  end

  def destroy?
    owns_record?
  end

  def share?
    update?
  end

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end

  private

  def owns_record?
    record.user == user
  end
end
