class Topic < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  scope :featured, -> { where.not(featured_at: nil).order(featured_at: :desc) }
  has_many :sign_topics, dependent: :destroy
  has_many :signs, through: :sign_topics

  NO_TOPIC_DESCRIPTION = "Other signs".freeze

  def featured
    featured_at.present?
  end

  def featured=(value)
    self.featured_at = value.to_i == 1 ? Time.zone.now : nil
  end
end
