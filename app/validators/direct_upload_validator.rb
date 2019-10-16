class DirectUploadValidator
  class Validatable
    include ActiveModel::Model
    attr_accessor :attachment

    validates :attachment,
              content_type: { with: Sign::PERMITTED_CONTENT_TYPE_REGEXP },
              size: { less_than_or_equal_to: Sign::MAXIMUM_VIDEO_FILE_SIZE }
  end

  def validate!(args)
    blob = ActiveStorage::Blob.new(args)
    file = OpenStruct.new(blob: blob, attached?: true)
    validatable = Validatable.new(attachment: file)
    validatable.valid? || fail(ActiveRecord::RecordInvalid, validatable)
  end
end
