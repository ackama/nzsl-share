# frozen_string_literal: true

module Admin
  class ApplicationController < Administrate::ApplicationController
    include Administrate::Punditize
    helper PresentersHelper

    before_action :authenticate_user!, :redirect_non_admins

    private

    def redirect_non_admins
      redirect_to root_path unless current_user.try(:administrator)
    end
  end
end
