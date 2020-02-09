# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def create?
    sign_owner? || (user&.approved? || sign_collaborator?) || user&.administrator?
  end

  def update?
    sign_owner? || user&.administrator?
  end

  def destroy?
    sign_owner? || user&.administrator?
  end

  def reply?
    sign_owner? || user&.approved? || user&.administrator?
  end

  def options?
    sign_owner? || user&.approved? || user&.administrator?
  end

  private

  def sign_collaborator?
    return unless user

    record.joins(folders: :collaborator).where(collaborations: { collaborator_id: user.id }).exists?
  end

  def sign_owner?
    return false if record.try(:sign).blank?

    record.sign.contributor == user
  end
end
