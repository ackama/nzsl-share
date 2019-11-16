class StaticController < ApplicationController
  def show
    return unless "about contact".include? params[:page]

    render params[:page]
  end
end
