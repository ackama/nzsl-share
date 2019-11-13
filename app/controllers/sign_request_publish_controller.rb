class SignRequestPublishController < ApplicationController
  before_action :authenticate_user!

  def destroy
    @sign = signs.find(params["sign_id"])
    @sign.request_unpublish
    authorize @sign, :request_unpublish?
    @sign.save

    redirect_back(fallback_location: @sign, notice: t(".success"))
  end

  private

  def signs
    policy_scope(Sign).order(word: :asc)
  end
end
