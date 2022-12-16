class SignWorkflowController < ApplicationController
  before_action :authenticate_user!

  def publish
    sign.publish!
    succeeded
  end

  def unpublish
    sign.unpublish!
    succeeded(redirect_back: false)
  end

  def cancel_submit
    sign.cancel_submit!
    succeeded
  end

  def request_unpublish
    sign.request_unpublish!
    succeeded
  end

  def cancel_request_unpublish
    sign.cancel_request_unpublish!
    succeeded
  end

  def decline
    sign.decline!
    succeeded(redirect_back: false)
  end

  # Unused - this transition is invoked from the
  # signs update action.
  # It is recorded here since it is the only transition
  # _not_ in this controller
  # def submit
  #   sign.submit!
  #   succeeded
  # end

  private

  def succeeded(redirect_back: true)
    if redirect_back
      redirect_back(fallback_location: redirect_location, notice: success_messsage)
    else
      redirect_to redirect_location, notice: success_messsage
    end
  end

  def redirect_location
    return sign if policy(sign).show?
    return admin_signs_path if current_user.administrator? || current_user.moderator?

    public_signs_path
  end

  def success_messsage
    admin_referer = _routes.recognize_path(request.referer).fetch(:controller, "").starts_with?("admin/")
    admin_referer ? t("admin.sign_workflow.#{params[:action]}.success") : t(".success")
  end

  def sign
    @sign ||= policy_scope(Sign)
              .find(params[:id])
              .tap { |sign| authorize sign }
  end
end
