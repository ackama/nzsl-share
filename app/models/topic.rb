class Topic < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  has_many :signs, inverse_of: :topic, dependent: :destroy
  scope :featured, -> { where.not(featured_at: nil).order(featured_at: :desc) }
end
