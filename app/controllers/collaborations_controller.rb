class CollaborationsController < ApplicationController
  def new
    @collaboration = Collaboration.new
    @folder = Folder.find(params[:folder_id])
    authorize @collaboration
  end

  def create
    builder = CollaborationBuilder.new(policy_scope(Collaboration), collaboration_params)
    @collaboration = builder.build
    authorize @collaboration
    unless @collaboration.save
      @folder = @collaboration.folder
      authorize @folder, :edit?
      render :new
      return
    end

    CollaborationMailer.success(@collaboration).deliver_later
    redirect_after_save
  end

  def destroy
    @collaboration = policy_scope(Collaboration).find(params[:id])
    authorize @collaboration
    redirect_back fallback_location: folders_path
    @collaboration.destroy ? { notice: t(".success") } : { alert: t(".failure") }
  end

  private

  def collaboration_params
    params.require(:collaboration).permit(:folder_id, :identifier)
  end

  def redirect_after_save
    flash[:notice] = t(".success")

    respond_to do |format|
      format.js { render inline: "location.reload();" }
      format.html { redirect_to folders_path }
    end
  end
end
