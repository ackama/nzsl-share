# frozen_string_literal: true

class ShareController < ApplicationController
  before_action :authenticate_user!

  def create
    with_exception_handling do
      @folder = fetch_folder
      authorize @folder
      @folder.update(share_token: SecureRandom.uuid)
      redirect_to_folders
    end
  end

  def destroy
    with_exception_handling do
      @folder = fetch_folder_by_token
      authorize @folder
      @folder.update(share_token: nil)
      redirect_to_folders
    end
  end

  def show
    with_exception_handling do
      @folder = fetch_folder_by_token
      authorize @folder
      render "folders/show"
    end
  end

  private

  def with_exception_handling
    yield if block_given?
  rescue ActiveRecord::RecordNotFound
    redirect_to_folders
  end

  def fetch_folder
    policy_scope(Folder).find_by!(id: folder_id)
  end

  def fetch_folder_by_token
    policy_scope(Folder).find_by!(id: folder_id, share_token: share_token)
  end

  def redirect_to_folders
    redirect_to folders_path
  end

  def folder_id
    params[:folder_id]
  end

  def share_token
    params[:id]
  end
end
