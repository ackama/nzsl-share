class SignWorkflowController < ApplicationController
  before_action :authenticate_user!
  after_action :succeeded

  def publish
    @sign.publish!
  end

  def unpublish
    @sign.unpublish!
  end

  def cancel_submit
    @sign.cancel_submit!
  end

  def request_unpublish
    @sign.request_unpublish!
  end

  def cancel_request_unpublish
    @sign.cancel_request_unpublish!
  end

  def decline
    @sign.decline!
  end

  # Unused - this transition is invoked from the
  # signs update action.
  # It is recorded here since it is the only transition
  # _not_ in this controller
  # def submit
  #   @sign.submit!
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
