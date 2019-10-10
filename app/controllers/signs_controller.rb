class SignsController < ApplicationController
  def show
    @sign = Sign.includes(:contributor, :topic)
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
    @signs = policy_scope(Sign).order("english ASC")
  end
end
