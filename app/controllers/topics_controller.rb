class TopicsController < ApplicationController
  def index
    @topics = policy_scope(Topic)
              .order(name: :asc)
  end

  def show
    @topic = policy_scope(Topic).find(params[:id])
    @signs = policy_scope(@topic.signs)
    authorize @topic
  end

  def uncategorised
    @topic = Topic.new(name: Topic::NO_TOPIC_DESCRIPTION)
    authorize @topic, :show?
    @signs = policy_scope(Sign).uncategorised

    render :show
  end
end
