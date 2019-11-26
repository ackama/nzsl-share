# frozen_string_literal: true

module Admin
  class SignsController < Admin::ApplicationController
    def scoped_resource
      policy_scope(Sign)
    end
  end
end
