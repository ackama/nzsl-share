# frozen_string_literal: true

class SignShareController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def create
    @sign = fetch_sign
    authorize @sign, :share?
    @sign.share_token = SecureRandom.uuid if @sign.share_token.blank?
    @sign.save(validate: false) # cannot directly update due to sign validations
    redirect_back(fallback_location: @sign, notice: t(".success", share_url: share_url))
  end

  def destroy
    @sign = fetch_sign
    authorize @sign, :share?
    @sign.share_token = nil if @sign.share_token.present?
    @sign.save(validate: false) # cannot directly update due to sign validations
    redirect_back(fallback_location: @sign, notice: t(".success"))
  end

  def show
    @sign = present(fetch_sign_by_token)
    authorize share_data, policy_class: SharePolicy

    render "signs/show"
  end

  private

  def share_data
    { shared: @sign.object, token: share_token } # pull the sign from the presenter
  end

  def share_url
    sign_share_url(@sign, @sign.share_token)
  end

  def fetch_sign
    policy_scope(Sign).find_by!(id: sign_id)
  end

  def fetch_sign_by_token
    policy_scope(Sign, policy_scope_class: SharePolicy::Scope).find_by!(id: sign_id, share_token: share_token)
  end

  def sign_id
    params[:sign_id]
  end

  def share_token
    params[:token]
  end
end
