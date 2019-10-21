# frozen_string_literal: true

class Search
  include ActiveModel::Model

  DEFAULT_DIRECTION = "ASC"
  DIRECTION = /\A(asc|desc)\Z/i.freeze
  PAGE = /\A[0-9]{1,2}\Z/.freeze
  DEFAULT_LIMIT = 16

  attr_reader :word, :order, :total

  def word=(value)
    @word = value.to_s.strip[0, 50] # is 50 to much?
  end

  def order=(value)
    @order = if match_direction(value).present?
               { fetch_key(value).to_s => match_direction(value).to_s }
             else
               {}
             end
  end

  def total=(value)
    @total = value.to_i
  end

  def page
    @page || build_page(DEFAULT_LIMIT)
  end

  def direction
    fetch_value(order) || DEFAULT_DIRECTION
  end

  def page=(value)
    limit = if match_page(value).blank?
              DEFAULT_LIMIT
            else
              DEFAULT_LIMIT * value.to_i
            end

    @page = build_page(limit)
  end

  def order_name
    fetch_key(order)
  end

  def page_with_total
    page.merge!(total: total)
  end

  private

  def match_direction(value)
    value.values.first.to_s.match(DIRECTION)
  end

  def match_page(value)
    value.to_s.match(PAGE)
  end

  def fetch_key(value)
    value.keys.first.to_s if search_hash?(value)
  end

  def fetch_value(value)
    value.values.first.to_s if search_hash?(value)
  end

  def search_hash?(value)
    value.present? && value.is_a?(Hash)
  end

  def build_page(limit)
    page = (limit.to_f / DEFAULT_LIMIT).ceil
    {
      current_page: page,
      next_page: page + 1,
      limit: limit,
      word: word
    }
  end
end
