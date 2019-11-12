class SignRequestPublishPolicy < ApplicationPolicy
  def destroy?
    owns_record?
  end

  private

  def owns_record?
    record.contributor == user
  end
end
