# frozen_string_literal: true

class SignComment < ApplicationRecord
  belongs_to :user
  belongs_to :sign
  belongs_to :folder, optional: true

  belongs_to :in_reply_to, class_name: "SignComment",
                           foreign_key: :parent_id,
                           inverse_of: :replies,
                           optional: true

  has_many :replies, -> { order(created_at: :asc) }, class_name: "SignComment",
                                                     foreign_key: "parent_id",
                                                     dependent: :destroy,
                                                     inverse_of: :in_reply_to # for rubocop

  has_many :reports,
           class_name: "CommentReport",
           inverse_of: :comment,
           dependent: :destroy,
           foreign_key: :comment_id

  has_many :activities, class_name: "SignCommentActivity",
                        inverse_of: :sign_comment,
                        dependent: :destroy

  has_one_attached :video

  validates :sign_status, presence: true
  validates :comment, presence: true, length: { maximum: 1000 }

  scope :read_by, lambda { |user|
    includes(:activities)
      .where(
        activities: {
          user:,
          key: SignCommentActivity.keys[:read]
        }
      )
  }

  scope :unread_by, ->(user) { where.not(id: read_by(user)) }

  def self.comment_types
    [["Text comment", "text"], ["NZSL comment", "video"]]
  end

  def video_description
    return unless video && video.attached?

    video.blob.metadata[:description] || ""
  end

  def read_by!(user)
    activities.read.where(user:).first_or_create!
  end

  def read_by?(user)
    self.class.read_by(user).exists?(sign_comments: { id: })
  end

  def remove
    update!(removed: true)
    activities.destroy_all
    reports.destroy_all
  end
end
