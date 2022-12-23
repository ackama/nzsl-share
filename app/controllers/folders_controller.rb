class FoldersController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize folders
  end

  def show
    @folder = policy_scope(Folder).find(id)
    authorize @folder
    render :show
  end

  def new
    @folder = Folder.new
    authorize @folder
  end

  def edit
    @folder = folders.find(id)
    authorize @folder
  end

  def create
    @folder = folders.build(folders_params)
    authorize @folder
    return render :new unless @folder.save

    @folder.collaborators << @folder.user
    redirect_after_save
  end

  def update
    @folder = folders.find(id)
    @folder.assign_attributes(folders_params)
    authorize @folder
    return render :edit unless @folder.save

    redirect_after_save
  end

  def destroy
    @folder = folders.find(id)
    authorize @folder

    redirect_to folders_path,
                (@folder.destroy ? { notice: t(".success") } : { alert: t(".failure") })
  end

  private

  def folders
    @folders = policy_scope(Folder).order("title ASC")
  end

  def folders_params
    params.require(:folder).permit(:title, :description, :user_id)
  end

  def redirect_after_save
    flash[:notice] = t(".success")

    respond_to do |format|
      format.js { render inline: "location.reload();" } # rubocop:disable Rails/RenderInline
      format.html { redirect_to folders_path }
    end
  end

  def id
    params[:id]
  end
end
