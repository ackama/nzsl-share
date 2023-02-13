# frozen_string_literal: true

class SignShareController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def show
    @sign = present(fetch_sign_by_token)
    authorize share_data, policy_class: SharePolicy

    @sign.topic = fetch_referer
    sign_comments

    render "signs/show"
  end

  def create
    @sign = fetch_sign
    authorize @sign, :share?
    @sign.update(share_token: @sign.share_token || SecureRandom.uuid)
    redirect_back(fallback_location: @sign, notice: t(".success", share_url:))
  end

  def destroy
    @sign = fetch_sign
    authorize @sign, :share?
    @sign.update(share_token: nil)
    redirect_back(fallback_location: @sign, notice: t(".success"))
  end

  private

  def sign_comments
    @comments = policy_scope(@sign.sign_comments
                .includes(user: :avatar_attachment)).where(folder_id: comments_folder_id)
                .page(params[:comments_page]).per(10)
  end

  def share_data
    { shared: @sign.object, token: share_token } # pull the sign from the presenter
  end

  def share_url
    sign_share_url(@sign, @sign.share_token)
  end

  def fetch_sign
    policy_scope(Sign).find(sign_id)
  end

  def fetch_sign_by_token
    policy_scope(Sign, policy_scope_class: SharePolicy::Scope).find_by!(id: sign_id, share_token:)
  end

  def comments_folder_id
    fallback = if @sign.published? || @sign.unpublish_requested?
                 nil
               else
                 policy_scope(@sign.folders).first
               end

    params[:comments_in_folder].presence || fallback
  end

  def fetch_referer
    request.referer ? URI(request.referer).path : nil
  end

  def sign_id
    params[:sign_id]
  end

  def share_token
    params[:token]
  end
end
