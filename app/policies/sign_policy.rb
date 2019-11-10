class SignPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    contributor?
  end

  def new?
    create?
  end

  def update?
    owns_record?
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

  private

  def owns_record?
    record.contributor == user
  end

  def contributor?
    user.present?
  end
end
