class SignPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || owns_record? || moderator?
  end

  def create?
    contributor?
  end

  def new?
    create?
  end

  def update?
    (owns_record? && !record.published? && !record.unpublish_requested?) || moderator?
  end

  def edit?
    update?
  end

  def destroy?
    owns_record?
  end

  def manage?
    owns_record?
  end

  def unpublish?
    manage?
  end

  def request_unpublish
    manage?
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
