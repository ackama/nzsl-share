# frozen_string_literal: true

module Admin
  class ApplicationController < Administrate::ApplicationController
    include Administrate::Punditize
    helper PresentersHelper

    before_action :authenticate_user!
    before_action { authorize :admin, :index? }

    rescue_from Pundit::NotAuthorizedError, with: :not_authorized

    private

    def not_authorized
      redirect_to root_path
    end
  end
end
