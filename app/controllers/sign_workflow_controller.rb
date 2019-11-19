class SignWorkflowController < ApplicationController
  before_action :authenticate_user!

  def publish
    sign.publish!
    succeeded
  end

  def unpublish
    sign.unpublish!
    succeeded
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
    succeeded
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

  def succeeded
    redirect_back(fallback_location: @sign, notice: t(".success"))
  end

  def sign
    @sign ||= policy_scope(Sign)
              .find(params[:sign_id])
              .tap(&method(:authorize))
  end
end
