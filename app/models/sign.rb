# frozen_string_literal: true

class Sign < ApplicationRecord
  belongs_to :contributor, class_name: :User
  belongs_to :topic, optional: true

  def agree_count; 0; end
  def disagree_count; 0; end
end
