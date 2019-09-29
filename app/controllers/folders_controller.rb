class FoldersController < ApplicationController
  before_action :authenticate_user!

  def index
    folders
  end

  def new
    @folder = Folder.new
  end

  def create
    if @folder.save
      redirect_to folders_path, notice: "Folder was successfully created."
    else
      render :new
    end
  end

  private

  def folders
    @folders = current_user.folders
  end
end
