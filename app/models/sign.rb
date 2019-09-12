# frozen_string_literal: true

class Sign < ApplicationRecord
  validates :english, length: 3..256, allow_blank: false

  class << self
    def search(title)
      return [] if title.blank?

      return [] unless title.strip.size.between?(3, 25)

      where(["LOWER(english) LIKE ?", "%#{sanitize_sql_like(title.strip.downcase)}%"])
    end
  end
end
