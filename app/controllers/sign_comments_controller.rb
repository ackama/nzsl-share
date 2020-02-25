# frozen_string_literal: true

class SignCommentsController < ApplicationController
  include ActionView::RecordIdentifier
  def create
    @sign = fetch_sign
    @sign_comment = SignComment.new(build_text_comment)
    authorize_create!(@sign_comment)

    @sign_comment.save
    @sign.reload
    refresh_comments
  end

  def edit
    @sign = fetch_sign
    @sign_comment = fetch_sign_comment
    authorize @sign_comment

    render
  end

  def update
    @sign = fetch_sign
    @sign_comment = fetch_sign_comment
    authorize @sign_comment
    @sign_comment.update(build_text_comment.merge(display: true))

    refresh_comments
  end

  def destroy
    @sign = fetch_sign
    @sign_comment = fetch_sign_comment
    authorize @sign_comment
    SignComment.remove(@sign_comment)
    if request.referer.include?("admin/comment_reports")
      respond_to do |format|
        format.js { render js: "window.location.href = '#{admin_comment_reports_path}'" }
      end
    else
      @sign.reload
      refresh_comments
    end
  end

  private

  def refresh_comments
    redirect_to polymorphic_path(@sign, comments_in_folder: @sign_comment.folder_id, anchor: dom_id(@sign_comment))
  end

  def authorize_create!(sign_comment)
    policy = SignCommentPolicy.new(
      current_user,
      sign_comment,
      current_folder_id: sign_comment.folder_id)

    return true if policy.create?

    fail NotAuthorizedError, query: :create, record: sign_comment, policy: policy
  end

  def comment_params
    params.require(:sign_comment).permit(:comment, :parent_id, :anonymous, :folder_id)
  end

  def build_text_comment
    {
      comment: Sanitizer.sanitize(comment_params[:comment]),
      parent_id: comment_params[:parent_id],
      anonymous: comment_params[:anonymous],
      folder_id: comment_params[:folder_id],
      sign_status: @sign.status,
      sign: @sign,
      user: current_user
    }
  end

  def fetch_sign_comment
    policy_scope(SignComment).find_by(id: id, sign_id: sign_id)
  end

  def fetch_sign
    policy_scope(Sign).find_by!(id: sign_id)
  end

  def sign_id
    params[:sign_id]
  end

  def id
    params[:id]
  end
end
