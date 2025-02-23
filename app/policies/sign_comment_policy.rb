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
    !folder_context? && !record.reports.exists?(user:) && !comment_author?
  end

  private

  def comment_author?
    return false unless user

    record.user == user
  end

  def folder_context?
    return false if @current_folder_id.blank?

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

  class Scope < Scope
    def resolve
      accessible_signs = SignPolicy::Scope.new(user, Sign.where(id: scope.pluck(:sign_id))).resolve
      folder_ids = accessible_signs.left_outer_joins(:folders).pluck("folders.id").compact
      accessible_folders = FolderPolicy::Scope.new(user, Folder.where(id: folder_ids)).resolve

      scope
        .where(sign_id: accessible_signs.pluck("signs.id"))
        .where(folder_id: [nil, *accessible_folders])
    end
  end
end
