# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def create?
    sign_owner? || user&.approved? || user&.administrator?
  end

  def update?
    record.user == user || user&.administrator?
  end

  def edit?
    update?
  end

  def destroy?
    record.user == user || user&.administrator?
  end

  def reply?
    sign_owner? || user&.approved? || user&.administrator?
  end

  def options?
    sign_owner? || user&.approved? || user&.administrator?
  end

  private

  def sign_owner?
    return false if record.try(:sign).blank?

    record.sign.contributor == user
  end
end
