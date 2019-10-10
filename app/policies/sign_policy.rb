class SignPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
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

  class Scope < Scope
    def resolve
      scope.where(contributor: user)
    end
  end

  private

  def owns_record?
    record.contributor == user
  end
end
