# frozen_string_literal: true

class FolderShareController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def create
    @folder = fetch_folder
    authorize @folder, :share?
    @folder.update(share_token: SecureRandom.uuid) if @folder.share_token.blank?

    redirect_back fallback_location: @folder, notice: t(".success", share_url: share_url)
  end

  def destroy
    @folder = fetch_folder_by_token
    authorize @folder, :share?
    @folder.update(share_token: nil)

    redirect_back fallback_location: @folder, notice: t(".success")
  end

  def show
    @folder = Folder.find_by!(id: folder_id, share_token: share_token)
    authorize share_data, policy_class: SharePolicy

    render "folders/show"
  end

  private

  def share_data
    { shared: @folder, token: share_token }
  end

  def share_url
    folder_share_url(@folder, @folder.share_token)
  end

  def fetch_folder
    policy_scope(Folder).find_by!(id: folder_id)
  end

  def fetch_folder_by_token
    policy_scope(Folder).find_by!(id: folder_id, share_token: share_token)
  end

  def folder_id
    params[:folder_id]
  end

  def share_token
    params[:token]
  end
end
