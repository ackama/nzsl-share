class StaticController < ApplicationController
  def show
    fail ActionController::RoutingError unless "about contact".include? params[:page]

    render params[:page]
  end
end
