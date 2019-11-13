class SignPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || owns_record? || moderator? || admin?
  end

  def create?
    contributor?
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

  def admin?
    return false if user.blank?

    user.administrator
  end

  class Scope < Scope
    def resolve_admin
      scope.where.not(submitted_at: nil).order(submitted_at: :desc)
    end
  end

  private

  def owns_record?
    record.contributor == user
  end

  def contributor?
    user.present?
  end
end
