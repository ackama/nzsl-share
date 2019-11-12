# frozen_string_literal: true

module Admin
  class ApplicationController < Administrate::ApplicationController
    helper PresentersHelper

    before_action :authenticate_user!
  end
end
