class SignDisagreementController < ApplicationController
  def create
    @activity = SignActivity.disagree!(sign: sign, user: current_user)
    authorize @activity
    @activity.save

    head :created
  end

  def destroy
    @activity = SignActivity.disagreement(sign: sign, user: current_user)
    authorize @activity
    @activity.destroy

    head :ok
  end

  private

  def sign
    @sign ||= policy_scope(Sign).find(params[:sign_id])
  end
end
