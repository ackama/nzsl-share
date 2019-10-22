class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError

  def self.perform_unique_later(*arguments)
    key = ActiveJob::Arguments.serialize(arguments)
    queue = Sidekiq::Queue.new(queue_as)
    queue.each do |job|
      # Skip queued jobs that are not from ActiveJob
      next if job.item["class"] != "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper"

      # Don't enqueue this job if it's already been enqueued with the same args
      # any? is used because the schema of the job structure is such that multiple "args"
      # values could be present.
      return false if job.item["args"].any? { |job_data| job_data["arguments"] == key }
    end

    perform_later(*arguments)
  end
end
