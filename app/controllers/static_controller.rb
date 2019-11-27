class StaticController < ApplicationController
  def show
    unless %w[about contact terms-and-conditions privacy-policy].include? params[:page]
    end

    render params[:page]
  end
end
