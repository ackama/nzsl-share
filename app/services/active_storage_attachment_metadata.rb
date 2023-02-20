class ActiveStorageAttachmentMetadata
  delegate :metadata, to: :@blob

  def initialize(attachment)
    @blob = attachment.blob
  end

  def set(key, value)
    metadata.merge!(key => value)
  end

  def set!(key, value)
    set(key, value).tap { save! }
  end

  def get(key)
    metadata.fetch(key, nil)
  end

  def all
    metadata.dup
  end

  private

  def save!
    @blob.update!(metadata:)
  end
end
