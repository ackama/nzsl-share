# frozen_string_literal: true

class Sign < ApplicationRecord
  belongs_to :contributor, class_name: :User
  belongs_to :topic, optional: true

  # For now, this just returns the first 4 signs
  # It is defined here so the concept of a sign preview
  # is shared amongst the application code and so we can
  # modify the rules later to take into account activity
  # or some other measure of popularity
  scope :preview, -> { limit(4) }
  scope :search, ->(ids) { where(id: ids) }
  scope :published_order, ->(direction) { order(published_at: direction) }
  scope :default_order, -> { order(english: :asc) }
  scope :search_limit, ->(limit) { limit(limit) }

  def agree_count; 0; end
  def disagree_count; 0; end
  def tags; []; end
end
