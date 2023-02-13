class SignDisagreementController < ApplicationController
  def create
    authorize sign, :disagree?
    @activity = SignActivity.disagree!(sign:, user: current_user)

    respond_to_success
  end

  def destroy
    @activity = SignActivity.disagreement(sign:, user: current_user)
    authorize @activity
    @activity.destroy

    respond_to_success
  end

  private

  def respond_to_success
    respond_to do |format|
      format.html { redirect_back(fallback_location: sign) }
      format.js { render votes_template }
    end
  end

  def votes_template
    parts = _routes.recognize_path(request.referer).slice(:controller, :action)
    parts == { controller: "signs", action: "show" } ? "signs/show/votes" : "signs/votes/votes"
  end

  def sign
    @sign ||= policy_scope(Sign).find(params[:sign_id])
  end
end
