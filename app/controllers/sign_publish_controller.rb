class SignPublishController < ApplicationController
  before_action :authenticate_user!

  def create
    @sign = my_signs.find(params["sign_id"])
    @sign.publish
    authorize @sign, :publish?
    @sign.save

    flash[:notice] = t(".success")
    redirect_after_update(@sign)
  end

  def destroy
    @sign = my_signs.find(params["sign_id"])
    @sign.set_sign_to_personal
    authorize @sign, :unpublish?
    @sign.save

    flash[:notice] = t(".success")
    redirect_after_update(@sign)
  end

  private

  def signs
    policy_scope(Sign).order(word: :asc)
  end

  def my_signs
    signs.where(contributor: current_user)
  end

  def redirect_after_update(sign)
    respond_to do |format|
      format.html { redirect_back(fallback_location: sign) }
      format.js { render inline: "window.location = '#{sign_path(sign)}'" }
    end
  end
end
