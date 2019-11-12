class SignPublishPolicy < ApplicationPolicy
  # def create?
  #   owns_record?
  # end

  def destroy?
    owns_record?
  end

  private

  def owns_record?
    record.contributor == user
  end
end
