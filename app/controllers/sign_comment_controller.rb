# frozen_string_literal: true

class SignCommentController < ApplicationController
  def create
    @sign = fetch_sign
    authorize @sign, policy_class: SignCommentPolicy
    @sign.sign_comments.new(build_comment).save
    refresh_comments
  end

  def update
    @sign = fetch_sign
    authorize @sign, policy_class: SignCommentPolicy
    @sign.sign_comments.find_by(id: id).update(comment_param)
    refresh_comments
  end

  def destroy
    @sign = fetch_sign
    authorize @sign, policy_class: SignCommentPolicy
    @sign.sign_comments.find_by(id: id).destroy
    refresh_comments
  end

  def reply
    @sign = fetch_sign
    authorize @sign, policy_class: SignCommentPolicy
    @sign.sign_comments.new(build_comment.merge(parent_id: id)).save
    refresh_comments
  end

  def appropriate
    @sign = fetch_sign
    authorize @sign, policy_class: SignCommentPolicy
    @sign.sign_comments.find_by(id: id).update(appropriate: false)
    refresh_comments
  end

  private

  def refresh_comments
    render partial: "sign_comments/refresh"
  end

  def comment_param
    params.require(:sign_comment).permit(:comment)
  end

  def build_comment
    { comment: comment_param[:comment], status: @sign.status, sign: @sign, user: current_user }
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
