class UserPolicy < ApplicationPolicy
  def edit?
    user && user.administrator?
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
