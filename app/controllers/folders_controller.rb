class FoldersController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize folders
  end

  def new
    @folder = Folder.new
    authorize @folder
  end

  def create
    @folder = folders.build(folders_params)
    authorize @folder
    return render :new unless @folder.save

    redirect_after_save
  end

  def edit
    @folder = folders.find(params[:id])
    authorize @folder
  end

  def update
    @folder = folders.find(params[:id])
    @folder.assign_attributes(folders_params)
    authorize @folder
    return render :edit unless @folder.save

    redirect_after_save
  end

  private

  def folders
    @folders = policy_scope(Folder).order("title ASC")
  end

  def folders_params
    params.require(:folder).permit(:title, :description)
  end

  def redirect_after_save
    flash[:notice] = t(".success")

    respond_to do |format|
      format.js { render inline: "location.reload();" }
      format.html { redirect_to folders_path }
    end
  end
end
