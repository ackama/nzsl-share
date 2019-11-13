class SignPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || owns_record? || moderator?
  end

  def create?
    return false unless contributor?
    return false if user.contribution_limit_reached?

    true
  end

  def new?
    create?
  end

  def update?
    owns_record? || moderator?
  end

  def edit?
    update?
  end

  def destroy?
    owns_record?
  end

  def manage_folders?
    return true if record.contributor == user
    return true unless record.status == "personal"

    false
  end

  def share?
    owns_record?
  end

  private

  def owns_record?
    record.contributor == user
  end

  def contributor?
    user.present?
  end
end
