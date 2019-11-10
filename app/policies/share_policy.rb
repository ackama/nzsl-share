# frozen_string_literal: true

class SharePolicy < ApplicationPolicy
  def show?
    record.fetch(:token) == record.fetch(:shared).share_token
  end
end
