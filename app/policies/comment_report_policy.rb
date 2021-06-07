# frozen_string_literal: true

class CommentReportPolicy < ApplicationPolicy
  def index?
    administrator?
  end

  def create?
    user&.approved? || user&.administrator?
  end

  def destroy?
    user&.administrator?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
