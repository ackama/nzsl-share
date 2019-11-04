# frozen_string_literal: true

class Sign < ApplicationRecord
  include AASM

  PERMITTED_CONTENT_TYPE_REGEXP = %r{\Avideo/.+\Z}.freeze
  MAXIMUM_VIDEO_FILE_SIZE = 250.megabytes

  belongs_to :contributor, class_name: :User
  belongs_to :topic, optional: true
  has_many :folder_memberships, dependent: :destroy
  has_many :folders, through: :folder_memberships
  has_one_attached :video

  validates :word, presence: true

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

  scope :for_cards, -> { includes(:contributor) }
  scope :search_default_order, lambda { |args|
    where(id: args[:ids])
      .order(word: args[:direction])
  }

  scope :search_published_order, lambda { |args|
    where(id: args[:ids])
      .order(published_at: args[:direction])
  }

  def agree_count; 0; end
  def disagree_count; 0; end
  def tags; []; end

  aasm whiny_transitions: false do
    state :personal, initial: true
    state :submitted, before_enter: -> { self.submitted_at = Time.zone.now }
    state :published, before_enter: -> { self.published_at = Time.zone.now }
    state :declined, before_enter: -> { self.declined_at = Time.zone.now }

    event :set_sign_to_personal do
      transitions from: %i[submitted declined], to: :personal
    end

    event :submit_for_publishing do
      transitions from: %i[personal declined], to: :submitted
    end

    event :publish do
      transitions from: %i[submitted], to: :published
    end

    event :decline do
      transitions from: %i[submitted published], to: :declined
    end
  end
end
