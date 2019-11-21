class DemographicPolicy < ApplicationPolicy
  def new?
    user && !user.approved?
  end

  def create?
    new?
  end
end
