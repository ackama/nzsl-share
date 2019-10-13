class SignsController < ApplicationController
  def show
    @sign = policy_scope(Sign.includes(:contributor, :topic))
            .find(params[:id])
    authorize @sign
    return unless stale?(@sign)

    render
  end

  def index
    authorize signs
  end

  def new
    @sign = Sign.new
    authorize @sign
  end

  private

  def signs
    @signs = policy_scope(Sign.where(contributor: current_user)).order("english ASC")
  end
end
