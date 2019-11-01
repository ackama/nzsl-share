# frozen_string_literal: true

class FolderShareController < ApplicationController
  before_action :authenticate_user!

  def create
    @folder = fetch_folder
    authorize @folder
    @folder.update(share_token: SecureRandom.uuid)
    flash[:notice] = t(".success", share_url: share_url)
    redirect_fallback
  end

  def destroy
    @folder = fetch_folder_by_token
    authorize @folder
    @folder.update(share_token: nil)
    flash[:notice] = t(".success")
    redirect_fallback
  end

  def show
    @folder = fetch_folder_by_token
    authorize @folder
    render "folders/show"
  end

  private

  def share_url
    "#{request.original_url}/#{@folder.share_token}"
  end

  def fetch_folder
    policy_scope(Folder).find_by!(id: folder_id)
  end

  def fetch_folder_by_token
    policy_scope(Folder).find_by!(id: folder_id, share_token: share_token)
  end

  def redirect_fallback
    redirect_back(fallback_location: @folder)
  end

  def folder_id
    params[:folder_id]
  end

  def share_token
    params[:id]
  end
end
