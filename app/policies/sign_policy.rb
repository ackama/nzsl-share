class SignPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || owns_record? || moderator? || administrator?
  end

  def create?
    contributor?
  end

  def new?
    create?
  end

  def update?
    (owns_record? || moderator?) && !public?
  end

  def edit?
    update?
  end

  def destroy?
    owns_record?
  end

  def manage?
    owns_record? || moderator?
  end

  def publish?
    (owns_record? && public?) || moderator?
  end

  def unpublish?
    (owns_record? && !public?) || moderator?
  end

  def request_unpublish?
    owns_record? && public?
  end

  def manage_folders?
    return true if record.contributor == user
    return true unless record.status == "personal"

    false
  end

  def share?
    owns_record?
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

  def public?
    record.published? || record.unpublish_requested?
  end
end
