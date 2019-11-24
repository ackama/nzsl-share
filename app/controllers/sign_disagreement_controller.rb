class SignDisagreementController < ApplicationController
  def create
    authorize sign, :disagree?
    @activity = SignActivity.disagree!(sign: sign, user: current_user)

    respond_to_success
  end

  def destroy
    @activity = SignActivity.disagreement(sign: sign, user: current_user)
    authorize @activity
    @activity.destroy

    respond_to_success
  end

  private

  def respond_to_success
    respond_to do |format|
      format.html { redirect_back(fallback_location: sign) }
      format.js { head :created }
    end
  end

  def sign
    @sign ||= policy_scope(Sign).find(params[:sign_id])
  end
end
