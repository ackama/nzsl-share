class TopicsController < ApplicationController
  def index
    @topics = policy_scope(Topic)
              .order(name: :asc)
  end
end
