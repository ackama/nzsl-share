class CachedVideoTranscoder
  delegate :service, to: :@blob

  def initialize(blob, options, processor: default_processor)
    @blob = blob
    @options = options
    @processor = processor.new(@options)
  end

  def exist?
    service.exist?(key)
  end

  def process_later
    TranscodeVideoJob.perform_unique_later(@blob, @options)
  end

  def processed
    ensure_active_storage_host
    return process unless processed?

    encoded_blob.url
  end

  private

  def processed?
    encoded_blob && service.exist?(encoded_blob.key)
  end

  def encoded_blob
    @encoded_blob ||= ActiveStorage::Blob.find_by(key:)
  end

  def ensure_active_storage_host
    ActiveStorage::Current.host ||= Rails.application.routes.default_url_options[:host]
  end

  def process
    @blob.purge if processed?

    @processor.transcode(@blob) do |file|
      service.upload(key, file[:io], **file)
      @encoded_blob = persist_blob(file)
      @encoded_blob.url
    end
  end

  def persist_blob(file)
    file[:io].rewind
    ActiveStorage::Blob
      .new(file.except(:io))
      .tap { |b| b.unfurl(file[:io]) }
      .tap { |b| b.key = key }
      .tap(&:save!)
  end

  # Use the same logic as the variation to determine the transcoded blob key
  # If the blob being transcoded is itself a variant, then remove the encoder options
  def key
    parts = @blob.key
                 .split("/", 3)
                 .take(2)
                 .reject { |str| str == "variants" }
                 .unshift("variants")

    "#{parts.join("/")}/#{Digest::SHA256.hexdigest(ActiveStorage::Variation.encode(@options))}"
  end

  def default_processor
    VideoTranscoder
  end
end
