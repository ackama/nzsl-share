# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def create?
    user&.approved? || (record.sign && !sign_published? && sign_collaborator?) || user&.administrator?
  end

  def update?
    record.user == user || user&.administrator?
  end

  def destroy?
    user&.administrator?
  end

  def reply?
    user&.approved? || user&.administrator?
  end

  def options?
    record.user == user || user&.administrator?
  end

  private

  def sign_published?
    record.sign.published? || record.sign.unpublish_requested?
  end

  def sign_collaborator?
    return unless user

    record.sign.folders.joins(:collaborations).where(collaborations: { collaborator_id: user.id }).exists?
  end

  def sign_owner?
    return false if record.try(:sign).blank?

    record.sign.contributor == user
  end
end
