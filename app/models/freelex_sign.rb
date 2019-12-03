# frozen_string_literal: true

class FreelexSign < ApplicationRecord
  self.primary_key = :headword_id
  scope :preview, -> { limit(4) }
end
