class SignAgreementController < ApplicationController
  def create
    authorize sign, :agree?
    @activity = SignActivity.agree!(sign: sign, user: current_user)

    respond_to_success
  end

  def destroy
    @activity = SignActivity.agreement(sign: sign, user: current_user)
    authorize @activity
    @activity.destroy

    respond_to_success
  end

  private

  def respond_to_success
    respond_to do |format|
      format.html { redirect_back(fallback_location: sign) }
      format.js { render "signs/card/votes", sign: sign }
    end
  end

  def sign
    @sign ||= policy_scope(Sign).find(params[:sign_id])
  end
end
