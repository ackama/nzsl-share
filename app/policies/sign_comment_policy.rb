# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def create?
    if private_sign?
      collaborator?
    else
      collaborator? || user&.approved? || user&.administrator?
    end
  end

  def update?
    comment_author? || user&.administrator?
  end

  def remove?
    comment_author? || user&.administrator?
  end

  def reply?
    create?
  end

  private

  def comment_author?
    return unless user

    record.user == user
  end

  def private_sign?
    return false if record.try(:sign).blank?

    record.sign.personal?
  end

  def collaborator?
    return false if record.try(:sign).blank? || !user

    record.sign.folders.left_outer_joins(:collaborations)
          .where(folders: { collaborations: { collaborator_id: user.id } })
          .any?
  end
end
