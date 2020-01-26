# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def create?
    approved_user?
  end

  def update?
    true
  end

  def destroy?
    true
  end

  def show?
    true
  end

  def reply?
    approved_user?
  end

  def options?
    approved_user?
  end

  private

  def approved_user?
    return false unless user

    user.approved?
  end
end
