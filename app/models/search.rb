# frozen_string_literal: true

class Search
  include ActiveModel::Model

  DIRECTION = /\A(0|1)\Z/.freeze
  PAGE = /\A[0-9]{1,2}\Z/.freeze
  LIMIT = 16

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

  def page
    @page || build_page(LIMIT)
  end

  def page=(value)
    limit = if value.to_s.match(PAGE).blank?
              LIMIT
            else
              LIMIT * value.to_i
            end

    @page = build_page(limit)
  end

  private

  def build_page(limit)
    page = (limit.to_f / LIMIT).ceil
    {
      this_page: page,
      next_page: page + 1,
      limit: limit,
      word: word,
      next_pub: fetch_published
    }
  end

  def fetch_published
    return "0" if published.nil?

    return "1" if published.downcase == "asc"

    "0"
  end
end
