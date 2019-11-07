class SignAttachmentsController < ApplicationController
  before_action :authenticate_user!

  def destroy
    authorize sign, :edit?
    attachment.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: edit_sign_path(sign)) }
      format.js { render }
    end
  end

  private

  def sign
    @sign ||= policy_scope(current_user.signs).find(params[:sign_id])
  end

  def attachment
    ActiveStorage::Attachment.where(record: sign).find(params[:id])
  end
end
