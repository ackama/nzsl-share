class UserPolicy < ApplicationPolicy
  def index?
    administrator?
  end

  def edit?
    administrator?
  end

  def update?
    edit?
  end

  def destroy?
    administrator? && record.signs.empty?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
