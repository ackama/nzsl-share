Sidekiq.configure_server do |config|
  config.redis = { db: Rails.env }
end
