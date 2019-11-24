class SignActivityPolicy < ApplicationPolicy
  def destroy?
    record.user == user
  end
end
