# frozen_string_literal: true

class SignComment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :sign
  has_many :replies, -> { order(created_at: :desc) }, class_name: "SignComment",
                                                      foreign_key: "parent_id",
                                                      dependent: :destroy,
                                                      inverse_of: false # satisfy rubocop

  validates :sign, presence: true
  validates :status, presence: true
  validates :comment, presence: true, length: { maximum: 1000 }
end
