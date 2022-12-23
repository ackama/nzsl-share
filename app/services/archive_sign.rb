class ArchiveSign
  def initialize(sign, user = nil)
    @sign = sign
    @user = user || SystemUser.find
  end

  # rubocop:disable Performance/MethodObjectAsBlock
  def process
    @sign
      .then(&:dup) # After this point we're acting on the copy
      .then(&method(:assign_attributes))
      .then(&method(:reassign_contributor))
      .then(&method(:copy_attachments))
      .tap(&:save!)
  end
  # rubocop:enable Performance/MethodObjectAsBlock

  private

  def assign_attributes(sign)
    sign.status = "archived"
    sign.share_token = nil
    sign
  end

  def reassign_contributor(sign)
    sign.contributor = @user
    sign
  end

  def copy_attachments(sign)
    sign.video_blob = @sign.video_blob
    sign.usage_examples_blobs = @sign.usage_examples_blobs
    sign.illustrations_blobs = @sign.illustrations_blobs

    sign
  end
end
