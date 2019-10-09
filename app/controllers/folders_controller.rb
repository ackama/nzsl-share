class FoldersController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize folders
  end

  def show
    @folder = if uuid?
                policy_scope(Folder).find_by!(share_token: id)
              else
                policy_scope(Folder).find_by!(id: id)
              end

    authorize @folder

    respond_to do |format|
      format.html { render :show }
    end
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

  def destroy
    @folder = folders.find(params[:id])
    authorize @folder

    redirect_to folders_path,
                (@folder.destroy ? { notice: t(".success") } : { alert: t(".failure") })
  end

  def share
    @folder = policy_scope(Folder).find_by!(id: id)
    authorize @folder
    @folder.update(share_token: SecureRandom.uuid)

    if @folder.errors.empty?
      redirect_to action: "show", id: @folder.share_token
    else
      render :new
    end
  end

  private

  UUID_SHAPE = /\A[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}\Z/i.freeze

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

  def id
    params[:id]
  end

  def uuid?
    id.to_s.match(UUID_SHAPE).present?
  end
end
