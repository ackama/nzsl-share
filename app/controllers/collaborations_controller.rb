class CollaborationsController < ApplicationController
  def new
    @collaboration = Collaboration.new
    @folder = Folder.find(params[:folder_id])
    authorize @collaboration
  end

  def create
    @collaboration = policy_scope(Collaboration).build(collaboration_params)
    authorize @collaboration
    return render :new unless @collaboration.save

    redirect_after_save
  end

  private

  def collaboration_params
    params.require(:collaboration).permit(:folder_id).merge(collaborator_id: find_collaborator.id)
  end

  def redirect_after_save
    flash[:notice] = t(".success")

    respond_to do |format|
      format.js { render inline: "location.reload();" }
      format.html { redirect_to folders_path }
    end
  end

  def find_collaborator
    identifier = params[:collaboration][:identifier]
    if identifier.include? "@"
      User.find_by(email: identifier)
    else
      User.find_by(username: identifier)
    end
  end
end
