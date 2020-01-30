# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def create?
    sign_owner? || user.administrator? || approved_user?
  end

  def update?
    sign_owner? || user.administrator?
  end

  def destroy?
    sign_owner? || user.administrator?
  end

  def show?
    true
  end

  def reply?
    sign_owner? || user.administrator? || approved_user?
  end

  def options?
    sign_owner? || user.administrator? || approved_user?
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
