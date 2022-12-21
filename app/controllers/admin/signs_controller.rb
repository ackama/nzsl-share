# frozen_string_literal: true

module Admin
  class SignsController < Admin::ApplicationController
    def index
      params[:search] ||= "pending:"
      super
    end

    def scoped_resource
      policy_scope(Sign).where.not(status: :personal)
    end
  end
end
