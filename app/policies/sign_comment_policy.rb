# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def initialize(user, record, current_folder_id: nil)
    super(user, record)
    @current_folder_id = current_folder_id
  end

  def create?
    if private_sign?
      sign_collaborator?
    else
      (sign_collaborator? && folder_context?) || user&.approved? || user&.administrator?
    end
  end

  def update?
    comment_author? || user&.administrator?
  end

  def destroy?
    update?
  end

  def reply?
    create?
  end

  def options?
    return true if user&.approved? && !folder_context?

    comment_author? || user&.administrator?
  end

  def report?
    !folder_context? && !record.reports.exists?(user: user) && !comment_author?
  end

  private

  def comment_author?
    return unless user

    record.user == user
  end

  def folder_context?
    return if @current_folder_id.blank?

    true
  end

  def private_sign?
    return false if record.try(:sign).blank?

    record.sign.personal?
  end

  def sign_collaborator?
    return false if record.try(:sign).blank? || !user

    record.sign.folders.left_outer_joins(:collaborations)
          .exists?(folders: { collaborations: { collaborator_id: user.id } })
  end
end
