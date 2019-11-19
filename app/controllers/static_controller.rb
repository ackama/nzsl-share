class StaticController < ApplicationController
  def show
    fail ActionController::RoutingError unless "about contact privacy-policy".include? params[:page]

    render params[:page]
  end
end
