class SignVideoCommentController < ApplicationController
  include ActionView::RecordIdentifier

  protect_from_forgery except: :create
  before_action :authenticate_user!
  after_action :post_process, only: :create

  def create
    @sign = fetch_sign
    @sign_comment = SignComment.new(create_params)

    authorize_create! @sign_comment

    @sign_comment.save
    @sign_comment_attachment = ActiveStorage::Attachment.new(attachment)
    @sign_comment_attachment.save

    render partial: "sign_comments/video_metadata"
  end

  def update
    @sign = fetch_sign
    @sign_comment = fetch_sign_comment
    authorize @sign_comment, :update?
    @sign_comment.update!(update_params)

    @metadata = metadata_service(@sign_comment.video.attachment)
    @metadata.set!(:description, Sanitizer.sanitize_text_with_urls(params[:sign_comment][:description]))

    refresh_comments
  end

  def destroy
    @sign = fetch_sign
    @sign_comment = fetch_sign_comment
    authorize @sign_comment, :destroy?
    @sign_comment.destroy
    refresh_comments
  end

  private

  def authorize_create!(sign_comment)
    policy = SignCommentPolicy.new(
      current_user,
      sign_comment,
      current_folder_id: sign_comment.folder_id)

    return true if policy.create?

    fail NotAuthorizedError, query: :create, record: sign_comment, policy: policy
  end

  def refresh_comments
    redirect_to polymorphic_path(@sign, comments_in_folder: @sign_comment.folder_id, anchor: dom_id(@sign_comment))
  end

  def fetch_sign_comment
    policy_scope(SignComment).find_by(id: comment_id, sign_id: sign_id)
  end

  def fetch_sign
    policy_scope(Sign).find_by!(id: sign_id)
  end

  def create_params
    {
      user: current_user,
      sign: @sign,
      sign_status: @sign.status,
      comment: Sanitizer.sanitize_text_with_urls(blob.filename.to_s),
      display: false,
      parent_id: params[:parent_id],
      folder_id: params[:folder_id]
    }
  end

  def update_params
    {
      folder_id: params[:sign_comment][:folder_id],
      anonymous: params[:sign_comment][:anonymous],
      display: true
    }
  end

  def attachment
    { name: "video", record_type: "SignComment", record_id: @sign_comment.id, blob_id: blob.id }
  end

  def post_process
    return unless @sign_comment_attachment.persisted?

    SignAttachmentPostProcessor.new(@sign_comment_attachment.blob).process
  end

  def metadata_service(attach)
    ActiveStorageAttachmentMetadata.new(attach)
  end

  def blob
    ActiveStorage::Blob.find_signed(signed_blob_id)
  end

  def signed_blob_id
    params.require(:signed_blob_id)
  end

  def sign_id
    params[:sign_id]
  end

  def comment_id
    params[:comment_id]
  end
end
