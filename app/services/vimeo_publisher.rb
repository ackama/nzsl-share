class VimeoPublisher
  ATTACHMENT_EXPIRY = 1.hour

  def initialize(client: nil, default_video_options: nil)
    @client = client || VimeoClient.new
    @default_video_options = default_video_options || \
                             Rails.application.config_for(:vimeo).fetch(:upload_options, {})
  end

  def publish(blob, metadata)
    params = default_video_options.dup
    params[:upload] = serialize_upload(blob)
    params.merge!(metadata)

    @client
      .post("/me/videos", params)
      .then { |response| assign_metadata(blob, response) }
      .then { VimeoThumbnailsJob.set(wait: 10.seconds).perform_later(blob) }
  end

  private

  def assign_metadata(blob, response)
    blob.metadata[:vimeo] = { id: response.id, link: response.link }
    blob.save!

    blob
  end

  def serialize_upload(blob)
    {
      approach: :pull,
      size: blob.byte_size,
      link: blob.service_url(expires_in: ATTACHMENT_EXPIRY)
    }
  end

  attr_reader :default_video_options
end
