# frozen_string_literal: true

module Admin
  class ApplicationController < Administrate::ApplicationController
    include Administrate::Punditize
    include ActiveStorage::SetCurrent
    helper PresentersHelper
    helper AvatarHelper

    before_action :authenticate_user!
    before_action { authorize :admin, :administrator_or_moderator? }
  end
end
