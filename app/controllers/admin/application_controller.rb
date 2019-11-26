# frozen_string_literal: true

module Admin
  class ApplicationController < Administrate::ApplicationController
    include Administrate::Punditize
    include ActiveStorage::SetCurrent
    helper PresentersHelper

    before_action :authenticate_user!
    before_action { authorize :admin, :index? }
  end
end
