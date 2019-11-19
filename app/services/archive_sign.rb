class ArchiveSign < ApplicationService
  def initialize(sign, user=nil)
    @sign = sign
    @user = user || SystemUser.find
  end

  def process
    @sign
      .then(&:dup) # After this point we're acting on the copy
      .then(&method(:reassign_contributor))
      .tap(&:save!)
      .then(&method(:copy_attachments))
  end

  private

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
