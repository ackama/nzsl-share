# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def create?
    true
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
    true
  end

  private

  def sign_owner?
    record.sign.contributor == user
  end
end
