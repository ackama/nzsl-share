# frozen_string_literal: true

class FreelexSign < ApplicationRecord
  validates :headword, length: 3..255, allow_blank: false
  validates_uniqueness_of :headword, case_sensitive: true
end
