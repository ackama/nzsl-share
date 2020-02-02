# frozen_string_literal: true

class SignCommentController < ApplicationController
  def create
    @sign = fetch_sign
    @sign_comment = SignComment.new(build_text_comment)
    authorize @sign_comment
    @sign_comment.save
    @sign.reload
    refresh_comments
  end

  def update
    @sign = fetch_sign
    @sign_comment = fetch_sign_comment
    authorize @sign_comment
    @sign_comment.update(build_text_comment.merge(display: true))
    @sign.reload
    refresh_comments
  end

  def destroy
    @sign = fetch_sign
    @sign_comment = fetch_sign_comment
    authorize @sign_comment
    @sign_comment.destroy
    @sign.reload
    refresh_comments
  end

  def appropriate
    @sign = fetch_sign
    @sign_comment = fetch_sign_comment
    authorize @sign_comment
    @sign_comment.update(appropriate: false)
    @sign.reload
    refresh_comments
  end

  private

  def refresh_comments
    respond_to do |format|
      format.html { redirect_back(fallback_location: @sign) }
      format.js   do
        @comments = policy_scope(@sign.sign_comments
          .includes(user: :avatar_attachment))
                    .where(folder_id: @sign_comment.folder_id)
        render partial: "sign_comments/refresh"
      end
    end
  end

  def comment_params
    params.require(:sign_comment).permit(:comment, :parent_id, :anonymous, :folder_id)
  end

  def build_text_comment
    {
      comment: comment_params[:comment],
      parent_id: comment_params[:parent_id],
      anonymous: comment_params[:anonymous],
      folder_id: comment_params[:folder_id],
      sign_status: @sign.status,
      sign: @sign,
      user: current_user
    }
  end

  def fetch_sign_comment
    policy_scope(@sign.sign_comments).find_by!(id: id)
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
