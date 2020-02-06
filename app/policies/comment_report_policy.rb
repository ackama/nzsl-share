# frozen_string_literal: true

class CommentReportPolicy < ApplicationPolicy
  def create?
    user
  end
end
