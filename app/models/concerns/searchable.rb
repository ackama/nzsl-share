# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def search(title)
      return [] if title.blank?

      return [] unless title.strip.size.between?(3, 25)

      where(["title like ?", "%#{sanitize_sql_like(title)}%"])
    end
  end
end
