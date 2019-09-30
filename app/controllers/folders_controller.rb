class FoldersController < ApplicationController
  before_action :authenticate_user!

  def index
    folders
    @folder = Folder.new
  end

  def create
    @folder = Folder.new(folders_params)
    respond_to do |format|
      if @folder.save
        format.js { flash[:notice] = "Folder successfully created." }
      else
        format.js { render :new }
      end
    end
  end

  private

  def folders
    @folders = current_user.folders
  end

  def folders_params
    params.require(:folder).permit(:title, :description, :user_id)
  end
end
