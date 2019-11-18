class SignPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    record.published? || owns_record? || moderator? || administrator?
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
    (owns_record? && !public?) || moderator? || administrator?
  end

  def edit?
    update?
  end

  def destroy?
    (owns_record? && !public?) || moderator? || administrator?
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
      scope
    end

    def search # rubocop:disable Metrics/AbcSize
      if user && (user.administrator || user.moderator)
        scope.all.ids
      elsif user
        scope.where("status = 'published' or status = 'unpublish_requested' or contributor_id = ?", user.id).ids
      else
        scope.where("status = 'published' or status = 'unpublish_requested'").ids
      end
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
