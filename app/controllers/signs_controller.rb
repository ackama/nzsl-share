class SignsController < ApplicationController
  def show
    @sign = policy_scope(Sign.includes(:contributor, :topic, :tags))
            .find(params[:id])
    authorize @sign
    return unless stale?(@sign)

    render
  end
end
