# frozen_string_literal: true

class Sign < ApplicationRecord
  PERMITTED_CONTENT_TYPE_REGEXP = %r{\Avideo/.+\Z}.freeze
  MAXIMUM_VIDEO_FILE_SIZE = 250.megabytes

  belongs_to :contributor, class_name: :User
  belongs_to :topic, optional: true
  has_one_attached :video

  validates :english, presence: true

  # See app/validators/README.md for details on these
  # validations
  validates :video, attached: true,
                    content_type: { with: PERMITTED_CONTENT_TYPE_REGEXP },
                    size: { less_than: MAXIMUM_VIDEO_FILE_SIZE }

  # For now, this just returns the first 4 signs
  # It is defined here so the concept of a sign preview
  # is shared amongst the application code and so we can
  # modify the rules later to take into account activity
  # or some other measure of popularity
  scope :preview, -> { limit(4) }

  def agree_count; 0; end
  def disagree_count; 0; end
  def tags; []; end
end
