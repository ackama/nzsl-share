class SignAttachmentsController < ApplicationController
  before_action :authenticate_user!
  after_action :post_process, only: :create

  def create
    authorize sign, :edit?
    @attachment = attachments.build(blob: blob)
    return head :created if sign.valid? && @attachment.save

    render json: sign.errors.full_messages, status: :unprocessable_entity
  end

  def update
    authorize sign, :edit?
    @metadata = metadata_service(attachment)
    @metadata.set!(:description, params[:description])

    respond_to do |format|
      format.html { redirect_back(fallback_location: edit_sign_path(sign)) }
      format.js { head(:ok) }
    end
  end

  def destroy
    authorize sign, :edit?
    attachment.destroy

    respond_to do |format|
      format.html { redirect_back(fallback_location: edit_sign_path(sign)) }
      format.js { head(:ok) }
    end
  end

  private

  def attachment
    attachments.find(params[:id])
  end

  def post_process
    return unless @attachment.persisted?

    SignAttachmentPostProcessor.new(@attachment.blob).process
  end

  def attachments
    sign.public_send(attachment_type)
  end

  def attachment_type
    params.require(:attachment_type)
  end

  def blob
    ActiveStorage::Blob.find_signed!(signed_blob_id)
  end

  def signed_blob_id
    params.require(:signed_blob_id)
  end

  def sign
    @sign ||= policy_scope(Sign)
              .find(params[:sign_id])
  end

  def metadata_service(attach)
    ActiveStorageAttachmentMetadata.new(attach)
  end
end
