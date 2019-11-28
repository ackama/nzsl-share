class StaticController < ApplicationController
  PAGES = %w[about contact terms-and-conditions privacy-policy].freeze
  def show
    fail ActionController::RoutingError, "Unknown page: #{params[:page]}" unless PAGES.include? params[:page]

    render params[:page]
  end
end
