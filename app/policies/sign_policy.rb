class SignPolicy < ApplicationPolicy
  def create?
    contributor?
  end

  def new?
    create?
  end

  private

  def contributor?
    user.present?
  end
end
