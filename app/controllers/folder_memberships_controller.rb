class FolderMembershipsController < ApplicationController
  def create
    @membership = policy_scope(FolderMembership).all.build(folder_membership_params)
    authorize @membership

    respond_to_modification(@membership.save)
  end

  def destroy
    @membership = policy_scope(FolderMembership).find(params[:id])
    authorize @membership

    respond_to_modification(@membership.destroy)
  end

  private

  def respond_to_modification(succeeded)
    return render(:modified) if request.format.js?

    modification_flashes(succeeded)
    redirect_back fallback_location: folders_path
  end

  def modification_flashes(succeeded)
    translation_interpolations = { sign: @membership.sign.english, folder: @membership.folder.title }

    if succeeded
      flash[:notice] = t(".success", translation_interpolations)
    else
      flash[:alert] = t(".failure", translation_interpolations)
    end
  end

  def folder_membership_params
    params.require(:folder_membership).permit(:folder_id, :sign_id)
  end
end
