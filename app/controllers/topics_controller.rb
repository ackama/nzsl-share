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
    # "uncategorised" isn't a topic
    # it references signs that LACK a topic
    @topic = Topic.new(name: Topic::NO_TOPIC_DESCRIPTION)
    @search_results ||= TopicSignService.new(search:, relation: policy_scope(Sign), topic: @topic).process
    @signs = @search_results.data
    @page = @search_results.support

    authorize @topic, :show?

    render :show
  end

  private

  def search
    @search ||= Search.new(params.permit(:page, :sort))
  end
end
