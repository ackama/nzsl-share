# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def create?
    sign_owner? || user&.approved? || user&.administrator?
  end

  def update?
    sign_owner? || user&.administrator?
  end

  def destroy?
    update?
  end

  def options?
    create?
  end

  def appropriate?
    create?
  end

  def reply?
    create?
  end

  private

  def approved_user?
    return false unless user

    user.approved?
  end

  def sign_owner?
    record.sign.contributor == user
  end
end
