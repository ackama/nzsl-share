class FoldersController < ApplicationController
  before_action :authenticate_user!

  def index
    @new_folder = Folder.new
    authorize @new_folder
    authorize folders
  end

  def new
    @folder = Folder.new
    authorize @folder
  end

  def create
    @folder = Folder.new(folders_params)
    authorize @folder
    respond_to do |format|
      if @folder.save
        format.js { flash[:notice] = "Folder successfully created." }
        format.html { redirect_to folders_path, notice: "Folder successfully created." }
      else
        format.js { render :new }
        format.html { render :new }
      end
    end
  end

  private

  def folders
    @folders = policy_scope(Folder).order("title ASC")
  end

  def folders_params
    params.require(:folder).permit(:title, :description, :user_id)
  end
end
