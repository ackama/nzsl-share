class SignVideoPublisher
  include Rails.application.routes.url_helpers
  include I18n

  # Allow this to be overridden for environments, e.g.
  # Test may use a null publisher, dev could use a local
  # publisher.
  cattr_accessor :default_publisher
  self.default_publisher = VimeoPublisher.new

  def initialize(sign, publisher: default_publisher)
    @sign = sign
    @publisher = publisher
  end

  def publish
    @publisher.publish(@sign.video.blob, metadata)
  end

  private

  def metadata
    word = @sign.english
    url = sign_url(@sign)

    {
      name: I18n.t("published_sign_video.name", word: word),
      description: I18n.t("published_sign_video.description", word: word, url: url)
    }
  end
end
