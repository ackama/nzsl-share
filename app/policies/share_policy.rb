# frozen_string_literal: true

class SharePolicy < ApplicationPolicy
  def show?
    record.fetch(:token) == record.fetch(:shared).share_token
  end

  class Scope < Scope
    def resolve
      scope.where.not(share_token: nil)
    end
  end
end
