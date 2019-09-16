# frozen_string_literal: true

class Sign < ApplicationRecord
  include Searchable

  validates :english, length: 3..256, allow_blank: false
end
