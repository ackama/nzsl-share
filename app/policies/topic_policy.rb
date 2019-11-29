class TopicPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def edit?
    administrator?
  end

  def new?
    administrator?
  end

  def create?
    administrator?
  end

  def destroy?
    administrator?
  end

  def update?
    administrator?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
