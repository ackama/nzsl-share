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

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
