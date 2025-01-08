class SignPolicy < ApplicationPolicy
  def initialize(user, record, current_folder_id: nil)
    super(user, record)
    @current_folder_id = current_folder_id
  end

  def index?
    true
  end

  def show?
    public_record? || owns_record? || (moderator? && !private_record?) || collaborator?
  end

  def create?
    contributor? && !user.contribution_limit_reached?
  end

  def new?
    create?
  end

  def update?
    (owns_record? && !public_record?) || (moderator? && !private_record?) || (collaborator? && !public_record?)
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

  def display_comments?
    return true if public_record?

    Pundit.policy_scope(user, record.folders).any?
  end

  def destroy?
    return false if public_record?

    owns_record? || moderator?
  end

  def overview?
    owns_record? || (!private_record? && moderator?) || collaborator?
  end

  def submit?
    record.may_submit? && owns_record? && approved?
  end

  def cancel_submit?
    record.may_cancel_submit? && owns_record? && approved?
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
    return true if owns_record? || public_record? || collaborator?

    false
  end

  def share?
    owns_record?
  end

  def permitted_attributes_for_update
    attributes = [:maori, :secondary, :notes, :word, :usage_examples, :illustrations, :conditions_accepted, {
      topic_ids: [] }]
    attributes << :video unless record.published?

    attributes
  end

  class Scope < Scope
    def resolve_admin
      scope
    end

    def resolve_moderator
      scope.where("contributor_id = ? or status != ?", user.id, "personal")
    end

    def resolve_user
      base = scope.left_outer_joins(folders: :collaborations)
      public_or_owned = base.where("status = 'published' or status = 'unpublish_requested' or contributor_id = ?",
                                   user.id)
      collaborative = base.where(folders: { collaborations: { collaborator_id: user.id } })
      Sign.where(id: public_or_owned.or(collaborative).distinct.pluck(:id))
    end

    def resolve_public
      scope.where("status = 'published' or status = 'unpublish_requested'")
    end

    def resolve
      if user&.moderator?
        collaboration_sign_ids =
          user.collaborations
              .joins(folder: :folder_memberships)
              .pluck("folder_memberships.sign_id")

        ids = (collaboration_sign_ids + resolve_moderator.map(&:id)).uniq
        scope.where(id: ids)
      elsif user
        resolve_user
      else
        resolve_public
      end
    end
  end

  private

  def public_record?
    record.published? || record.unpublish_requested?
  end

  def private_record?
    record.personal? || record.declined?
  end

  def owns_record?
    record.contributor == user
  end

  def contributor?
    user.present?
  end

  def collaborator?
    return false unless user

    record.folders.left_outer_joins(:collaborations)
          .exists?(folders: { collaborations: { collaborator_id: user.id } })
  end
end
