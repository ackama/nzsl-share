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

  has_one_attached :video

  validates :sign, presence: true
  validates :user, presence: true
  validates :sign_status, presence: true
  validates :comment, presence: true, length: { maximum: 1000 }

  def self.comment_types
    [["Text comment", "text"], ["NZSL comment", "video"]]
  end

  def video_description
    return unless video && video.attached?

    video.blob.metadata[:description]
  end
end
