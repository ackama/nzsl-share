class SignPublishVideoJob < ApplicationJob
  queue_as :sign_video_publishing

  def perform(sign, publisher: SignVideoPublisher.new)
    publisher.publish(sign)
  end
end
