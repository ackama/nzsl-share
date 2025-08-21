class TopicsController < ApplicationController
  def index
    @topics = policy_scope(Topic)
              .order(name: :asc)
  end

  def show
    @topic = policy_scope(Topic).find(params[:id])
    @search_results ||= TopicSignService.new(search:, relation: policy_scope(Sign), topic: @topic).process
    @signs = @search_results.data
    @page = @search_results.support

    authorize @topic
  end

  def uncategorised
    @topic = Topic.new(name: Topic::NO_TOPIC_DESCRIPTION)
    authorize @topic, :show?
    @signs = policy_scope(Sign).uncategorised

    render :show
  end

  private

  def search
    @search ||= Search.new(params.permit(:page, :sort))
  end
end
