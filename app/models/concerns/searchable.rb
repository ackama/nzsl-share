# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def search(title, lang=:english)
      return [] if title.blank?

      return [] unless title.strip.size.between?(3, 25)

      where(["LOWER(#{lang}) LIKE ?", "%#{sanitize_sql_like(title.strip.downcase)}%"])
    end
  end
end
