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

  def appropriate?
    true
  end

  def show?
    true
  end
end
