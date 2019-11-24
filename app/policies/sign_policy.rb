class SignPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || owns_record? || (moderator? && !record.personal?)
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
    (owns_record? && !public?) || (moderator? && !record.personal?)
  end

  def edit?
    update?
  end

  def disagree?
    user&.approved?
  end

  def agree?
    user&.approved?
  end

  def destroy?
    return false if public?

    owns_record? || moderator?
  end

  def overview?
    owns_record? || (!private_record? && moderator?)
  end

  def cancel_submit?
    record.may_cancel_submit? && owns_record?
  end

  def publish?
    record.may_publish? && moderator?
  end

  def unpublish?
    record.may_unpublish? && moderator?
  end

  def request_unpublish?
    record.may_request_unpublish? && owns_record?
  end

  def cancel_request_unpublish?
    record.may_cancel_request_unpublish? && (owns_record? || moderator?)
  end

  def decline?
    record.may_decline? && moderator?
  end

  def manage_folders?
    return true if owns_record? || public?

    false
  end

  def share?
    owns_record?
  end

  class Scope < Scope
    def resolve_admin
      scope
    end

    def resolve
      if user && user.moderator
        scope.where("contributor_id = ? or status != ?", user.id, "personal")
      elsif user
        scope.where("status = 'published' or status = 'unpublish_requested' or contributor_id = ?", user.id)
      else
        scope.where("status = 'published' or status = 'unpublish_requested'")
      end
    end
  end

  private

  def private_record?
    record.personal? || record.declined?
  end

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
