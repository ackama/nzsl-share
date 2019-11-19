class StaticController < ApplicationController
  def show
    fail ActionController::RoutingError unless "about contact terms-and-conditions".include? params[:page]

    render params[:page]
  end
end
