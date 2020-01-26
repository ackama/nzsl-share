# frozen_string_literal: true

class SignCommentPolicy < ApplicationPolicy
  def create?
    true
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
    true
  end
end
