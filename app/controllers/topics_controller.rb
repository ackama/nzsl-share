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
end
