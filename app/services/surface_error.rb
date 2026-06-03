class SurfaceError
  def initialize(message)
    @message = message
  end

  def log
    Rails.logger.error @message
    Raygun.track_exception(Exception.new(@message))
  end
end
