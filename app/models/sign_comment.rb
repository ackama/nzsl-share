# frozen_string_literal: true

class SignComment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :sign
  has_many :replies, -> { order(created_at: :desc) }, class_name: "SignComment",
                                                      foreign_key: "parent_id",
                                                      dependent: :destroy,
                                                      inverse_of: false # satisfy rubocop
  has_one_attached :video

  validates :sign, presence: true
  validates :sign_status, presence: true
  validates :comment, presence: true, length: { maximum: 1000 }, unless: -> { video.present? }
  validates :video, content_type: { with: Sign::PERMITTED_VIDEO_CONTENT_TYPE_REGEXP },
                    size: { less_than: Sign::MAXIMUM_FILE_SIZE }
end
