# frozen_string_literal: true

class SignShareController < ApplicationController
  before_action :authenticate_user!

  def create
    @sign = fetch_sign
    authorize @sign
    @sign.update(share_token: SecureRandom.uuid)
    flash[:notice] = t(".success", share_url: share_url)
    redirect_fallback
  end

  def destroy
    @sign = fetch_sign_by_token
    authorize @sign
    @sign.update(share_token: nil)
    flash[:notice] = t(".success")
    redirect_fallback
  end

  def show
    @sign = fetch_sign_by_token
    authorize @sign
    render "signs/show"
  end

  private

  def share_url
    "#{request.original_url}/#{@sign.share_token}"
  end

  def fetch_sign
    policy_scope(Sign).find_by!(id: sign_id)
  end

  def fetch_sign_by_token
    policy_scope(Sign).find_by!(id: sign_id, share_token: share_token)
  end

  def redirect_fallback
    redirect_back(fallback_location: @sign)
  end

  def sign_id
    params[:sign_id]
  end

  def share_token
    params[:id]
  end
end
