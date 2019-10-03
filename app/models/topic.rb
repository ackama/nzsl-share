class Topic < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  scope :featured, -> { where.not(featured_at: nil).order(featured_at: :desc) }
end
