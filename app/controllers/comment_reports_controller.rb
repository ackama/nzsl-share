class CommentReportsController < ApplicationController
  before_action :authenticate_user!

  def create
    @comment_report = comment.reports.build(comment_report_params)
    authorize(@comment_report) && @comment_report.save!
    redirect_to comment.sign, notice: t(".success")
  end

  private

  def comment_report_params
    { user: current_user, comment: comment }
  end

  def comment
    @comment ||= policy_scope(SignComment).find(params[:comment_id])
  end
end
