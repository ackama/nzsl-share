class StaticController < ApplicationController
  def show
    unless %w[about contact terms-and-conditions privacy-policy].include? params[:page]
      fail ActionController::RoutingError, "Unknown page: #{params[:page]}"
    end

    render params[:page]
  end
end
