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
    @sign_comment.update(comment: comment_param[:comment], display: true)
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

  def reply
    @sign = fetch_sign
    @sign_comment = SignComment.new(build_text_comment.merge(parent_id: id))
    authorize @sign_comment
    @sign_comment.save
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

  def video
    @sign = fetch_sign
    @sign_comment = SignComment.new(build_partial_video_comment)
    authorize @sign_comment
    @sign_comment.save
    @sign.reload
    refresh_comments
  end

  private

  def refresh_comments
    respond_to do |format|
      format.html { redirect_back(fallback_location: @sign) }
      format.js   { render partial: "sign_comments/refresh" }
    end
  end

  def comment_param
    params.require(:sign_comment).permit(:comment)
  end

  def video_param
    params.require(:sign_comment).permit(:video)
  end

  def build_text_comment
    { comment: comment_param[:comment], sign_status: @sign.status, sign: @sign, user: current_user }
  end

  def build_partial_video_comment
    build_text_comment.merge(video: video_param[:video], display: false)
  end

  def fetch_sign_comment
    policy_scope(SignComment).find_by!(id: id)
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
