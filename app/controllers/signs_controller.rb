class SignsController < ApplicationController
  before_action :authenticate_user!, except: %i[show]

  def show
    @sign = policy_scope(Sign.includes(:contributor, :topic))
            .find(params[:id])
    authorize @sign
    return unless stale?(@sign)

    render
  end
end
