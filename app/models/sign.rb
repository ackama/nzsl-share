# frozen_string_literal: true

class Sign < ApplicationRecord
  include AASM

  PERMITTED_VIDEO_CONTENT_TYPE_REGEXP = %r{\Avideo/.+\Z}.freeze
  PERMITTED_IMAGE_CONTENT_TYPE_REGEXP = %r{\Aimage/.+\Z}.freeze
  MAXIMUM_FILE_SIZE = 250.megabytes

  belongs_to :contributor, class_name: :User
  belongs_to :topic, optional: true
  has_many :folder_memberships, dependent: :destroy
  has_many :folders, through: :folder_memberships
  has_many :activities, class_name: "SignActivity", dependent: :destroy

  has_one_attached :video
  has_many_attached :usage_examples
  has_many_attached :illustrations

  validates :word, presence: true
  validates :conditions_accepted,
            presence: true,
            unless: -> { personal? || archived? }

  # See app/validators/README.md for details on these
  # validations
  validates :video, attached: true,
                    content_type: { with: PERMITTED_VIDEO_CONTENT_TYPE_REGEXP },
                    size: { less_than: MAXIMUM_FILE_SIZE }

  validates :usage_examples, content_type: { with: PERMITTED_VIDEO_CONTENT_TYPE_REGEXP },
                             size: { less_than: MAXIMUM_FILE_SIZE },
                             length: { maximum: 2 }

  validates :illustrations, content_type: { with: PERMITTED_IMAGE_CONTENT_TYPE_REGEXP },
                            size: { less_than: MAXIMUM_FILE_SIZE },
                            length: { maximum: 3 }

  # For now, this just returns the first 4 signs
  # It is defined here so the concept of a sign preview
  # is shared amongst the application code and so we can
  # modify the rules later to take into account activity
  # or some other measure of popularity
  scope :preview, -> { limit(4) }

  scope :recent, -> { published.order(published_at: :desc) }

  scope :for_cards, -> { with_attached_video.includes(:contributor) }

  def agree_count
    activities.where(key: SignActivity::ACTIVITY_AGREE, sign: self).count
  end

  def disagree_count
    activities.where(key: SignActivity::ACTIVITY_DISAGREE, sign: self).count
  end

  def tags; []; end

  aasm column: "status", whiny_transitions: false do # rubocop:disable Metrics/BlockLength
    state :personal, initial: true
    state :submitted, before_enter: -> { self.submitted_at = Time.zone.now }
    state :published, before_enter: -> { self.published_at = Time.zone.now }
    state :declined, before_enter: -> { self.declined_at = Time.zone.now }
    state :unpublish_requested, before_enter: -> { self.requested_unpublish_at = Time.zone.now }
    state :archived

    event :make_private do
      transitions from: %i[submitted declined], to: :personal
    end

    event :submit do
      transitions from: %i[personal], to: :submitted
    end

    event :cancel_submit do
      transitions from: %i[personal submitted], to: :personal
    end

    event :publish do
      transitions from: %i[unpublish_requested submitted], to: :published
    end

    event :unpublish, before: -> { ArchiveSign.call(self) },
                      after: -> { FolderMembership.where.not(id: FolderMembership.owner_of(self)).destroy_all } do
      transitions from: %i[unpublish_requested published],
                  to: :personal
    end

    event :request_unpublish do
      transitions from: %i[published], to: :unpublish_requested
    end

    event :cancel_request_unpublish do
      transitions from: :unpublish_requested, to: :published
    end

    event :decline do
      transitions from: %i[submitted published], to: :declined
    end
  end
end
