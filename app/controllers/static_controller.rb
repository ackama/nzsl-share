class StaticController < ApplicationController
  def show
    unless "about contact terms-and-conditions privacy-policy".include? params[:page]
      fail ActionController::RoutingError
    end

    render params[:page]
  end
end
