class DirectUploadValidator
  class Validatable
    include ActiveModel::Model
    attr_accessor :attachment

    ## It must be one of these
    def self.permitted_type
      Regexp.union(Sign::PERMITTED_IMAGE_CONTENT_TYPE_REGEXP, Sign::PERMITTED_VIDEO_CONTENT_TYPE_REGEXP)
    end

    def self.permitted_file_size
      Sign::MAXIMUM_FILE_SIZE
    end

    validates :attachment,
              content_type: { with: permitted_type },
              size: { less_than_or_equal_to: permitted_file_size }
  end

  def validate!(args)
    blob = ActiveStorage::Blob.new(args)
    file = OpenStruct.new(blob:, attached?: true) # rubocop:disable Style/OpenStructUse
    validatable = Validatable.new(attachment: file)
    validatable.valid? || fail(ActiveRecord::RecordInvalid, validatable)
  end
end
