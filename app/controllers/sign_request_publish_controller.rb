class SignRequestPublishController < ApplicationController
  before_action :authenticate_user!

  def destroy
    @sign = my_signs.find(params["sign_id"])
    @sign.request_unpublish
    authorize @sign, policy_class: SignRequestPublishPolicy
    @sign.save

    flash[:notice] = t(".success")
    redirect_after_update(@sign)
  end

  private

  def my_signs
    @signs = policy_scope(Sign.where(contributor: current_user)).order(word: :asc)
  end

  def redirect_after_update(sign)
    respond_to do |format|
      format.html { redirect_to sign }
      format.js { render inline: "window.location = '#{sign_path(sign)}'" }
    end
  end
end
