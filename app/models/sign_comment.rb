# frozen_string_literal: true

class SignComment < ApplicationRecord
  belongs_to :user
  belongs_to :sign
  has_many :replies, -> { order(created_at: :asc) }, class_name: "SignComment",
                                                     foreign_key: "parent_id",
                                                     dependent: :destroy,
                                                     inverse_of: false # for rubocop
  has_one_attached :video

  validates :sign, presence: true
  validates :user, presence: true
  validates :sign_status, presence: true
  validates :comment, presence: true, length: { maximum: 1000 }
end