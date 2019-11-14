class SignPublishController < ApplicationController
  before_action :authenticate_user!

  def create
    @sign = signs.find(params["sign_id"])
    @sign.publish
    authorize @sign, :publish?
    @sign.save

    redirect_back(fallback_location: @sign, notice: t(".success"))
  end

  def destroy
    @sign = signs.find(params["sign_id"])
    @sign.set_sign_to_personal
    authorize @sign, :unpublish?
    @sign.save

    redirect_back(fallback_location: @sign, notice: t(".success"))
  end

  private

  def signs
    policy_scope(Sign).order(word: :asc)
  end
end
