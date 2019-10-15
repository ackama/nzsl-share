# frozen_string_literal: true

class Sign < ApplicationRecord
  belongs_to :contributor, class_name: :User
  belongs_to :topic, optional: true
  has_many :folder_memberships, dependent: :destroy
  has_many :folders, through: :folder_memberships

  # For now, this just returns the first 4 signs
  # It is defined here so the concept of a sign preview
  # is shared amongst the application code and so we can
  # modify the rules later to take into account activity
  # or some other measure of popularity
  scope :preview, -> { limit(4) }

  scope :for_cards, -> { includes(:contributor) }
  scope :search_default_order, lambda { |args|
    where(id: args[:ids])
      .order(english: :asc)
  }

  scope :search_published_order, lambda { |args|
    where(id: args[:ids])
      .order(published_at: args[:direction])
  }

  def agree_count; 0; end
  def disagree_count; 0; end
  def tags; []; end
end
