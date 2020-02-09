# frozen_string_literal: true

class CommentReportPolicy < ApplicationPolicy
  def create?
    user&.approved?
  end

  def destroy?
    administrator?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
