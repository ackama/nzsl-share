class ApprovedUserApplicationPolicy < ApplicationPolicy
  def new?
    !approved?
  end

  def create?
    new?
  end

  def accept?
    administrator? && record.may_accept?
  end

  def decline?
    administrator? && record.may_decline?
  end
end
