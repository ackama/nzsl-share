# frozen_string_literal: true

class Search
  include ActiveModel::Model

  DIRECTION = /\A(0|1)\Z/.freeze

  attr_reader :word, :published

  def word=(value)
    @word = value.to_s[0, 50] # word limit 50 chars
  end

  def published=(value)
    return if value.to_s.match(DIRECTION).blank?

    direction = if value.to_s == "0"
                  "ASC"
                else
                  "DESC"
                end

    @published = direction
  end
end
