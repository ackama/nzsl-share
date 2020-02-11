# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def create?
    if private_sign?
      sign_collaborator?
    else
      (sign_collaborator? && folder_context?) || user&.approved? || user&.administrator?
    end
  end

  def update?
    record.user == user || user&.administrator?
  end

  def destroy?
    user&.administrator?
  end

  def reply?
    create?
  end

  def options?
    record.user == user || user&.administrator?
  end

  private

  def folder_context?
    return true unless record.sign.comments_in_folder == ""
  end

  def private_sign?
    return false if record.try(:sign).blank?

    record.sign.personal?
  end

  def sign_collaborator?
    return unless user

    record.sign.folders.joins(:collaborations).where(collaborations: { collaborator_id: user.id }).exists?
  end
end
