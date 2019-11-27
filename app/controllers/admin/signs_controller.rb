# frozen_string_literal: true

module Admin
  class SignsController < Admin::ApplicationController
    def scoped_resource
      @signs = policy_scope(Sign)

      @signs.where.not(status: "personal")
    end
  end
end
