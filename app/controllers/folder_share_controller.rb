# frozen_string_literal: true

class FolderShareController < ApplicationController
  before_action :authenticate_user!, except: [:show]

  def show
    @folder = fetch_folder_by_token
    authorize share_data, policy_class: SharePolicy

    search_results = FolderSignService.new(search:, relation: policy_scope(Sign), folder: @folder).process
    @signs = search_results.data
    @page = search_results.support

    render "folders/show"
  end

  def create
    @folder = fetch_folder
    authorize @folder, :share?
    @folder.update(share_token: @folder.share_token || SecureRandom.uuid)

    redirect_back fallback_location: @folder, notice: t(".success", share_url:)
  end

  def destroy
    @folder = fetch_folder
    authorize @folder, :share?
    @folder.update(share_token: nil)

    redirect_back fallback_location: @folder, notice: t(".success")
  end

  private

  def share_data
    { shared: @folder, token: share_token }
  end

  def share_url
    folder_share_url(@folder, @folder.share_token)
  end

  def fetch_folder
    policy_scope(Folder).find(folder_id)
  end

  def fetch_folder_by_token
    policy_scope(Folder, policy_scope_class: SharePolicy::Scope).find_by!(id: folder_id, share_token:)
  end

  def folder_id
    params[:folder_id]
  end

  def share_token
    params[:token]
  end

  def search
    @search ||= Search.new(params.permit(:page, :sort))
  end
end
