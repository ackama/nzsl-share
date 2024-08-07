# frozen_string_literal: true

class Sign < ApplicationRecord
  include AASM

  PERMITTED_VIDEO_CONTENT_TYPE_REGEXP = %r{\A(?:video/.+|application/mp4)\Z}
  PERMITTED_IMAGE_CONTENT_TYPE_REGEXP = %r{\Aimage/.+\Z}
  REFERRED_TOPIC = %r{\A/topics/\d+\Z}
  MAXIMUM_FILE_SIZE = 250.megabytes

  belongs_to :contributor, class_name: :User
  has_many :folder_memberships, dependent: :destroy
  has_many :folders, through: :folder_memberships
  has_many :activities, class_name: "SignActivity", dependent: :destroy
  has_many :sign_topics, dependent: :destroy
  has_many :topics, through: :sign_topics
  has_many :sign_comments, -> { where(parent_id: nil).order(created_at: :desc) }, dependent: :destroy, inverse_of: :sign

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
  scope :uncategorised, -> { left_outer_joins(:sign_topics).group(:id).having("COUNT(sign_topics.id) = 0") }

  scope :for_cards, lambda {
    includes(:topics,
             video_attachment: { blob: { preview_image_attachment: :blob } },
             folders: { folder_memberships: nil, collaborations: :collaborator },
             contributor: { avatar_attachment: :blob })
  }

  attr_reader :topic # breadcrumb for show template

  def topic=(path)
    tpc_id = if path && path.match(REFERRED_TOPIC)
               path.split("/")[2].to_i
             else
               SignTopic.where(sign_id: id)
                        .order(created_at: :asc)
                        .first.try(:topic_id)
             end

    @topic = tpc_id ? topics.find_by(id: tpc_id) : nil
  end

  def agree_count
    activities.where(key: SignActivity::ACTIVITY_AGREE, sign: self).count
  end

  def disagree_count
    activities.where(key: SignActivity::ACTIVITY_DISAGREE, sign: self).count
  end

  def tags; []; end

  aasm column: "status", whiny_transitions: false do # rubocop:disable Metrics/BlockLength
    state :personal, initial: true
    state :submitted, before_enter: -> { self.submitted_at = Time.zone.now },
                      after_enter: -> { SignWorkflowMailer.moderation_requested(self).deliver_later }
    state :published, before_enter: -> { self.published_at = Time.zone.now },
                      after_enter: -> { SignWorkflowMailer.published(self).deliver_later }
    state :declined, before_enter: -> { self.declined_at = Time.zone.now },
                     after_enter: -> { SignWorkflowMailer.declined(self).deliver_later }
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

    event :unpublish, before: -> { ArchiveSign.new(self).process },
                      after:
                      lambda {
                        FolderMembership.where(sign: self)
                                        .where.not(id: FolderMembership.owner_of(self))
                                        .destroy_all
                      } do
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
