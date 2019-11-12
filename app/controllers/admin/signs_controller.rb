# frozen_string_literal: true

module Admin
  class SignsController < Admin::ApplicationController
    private

    def scoped_resource
      resource_class.where.not(submitted_at: nil).order(submitted_at: :desc)
    end
  end
end
