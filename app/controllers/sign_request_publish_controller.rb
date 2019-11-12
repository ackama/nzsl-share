class SignRequestPublishController < ApplicationController
  before_action :authenticate_user!

  # def create
  #   @sign = Sign.find(params["sign_id"])
  #   @sign.publish
  #   authorize @sign, policy_class: SignRequestPublishPolicy
  #   @sign.save

  #   flash[:notice] = t(".success")
  #   redirect_after_update(@sign)
  # end

  def destroy
    @sign = Sign.find(params["sign_id"])
    @sign.request_unpublish
    authorize @sign, policy_class: SignRequestPublishPolicy
    @sign.save

    flash[:notice] = t(".success")
    redirect_after_update(@sign)
  end

  private

  def redirect_after_update(sign)
    respond_to do |format|
      format.html { redirect_to sign }
      format.js { render inline: "window.location = '#{sign_path(sign)}'" }
    end
  end
end
