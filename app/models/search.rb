# frozen_string_literal: true

class Search
  include ActiveModel::Model

  DIRECTION = /\A(asc|desc)\Z/i.freeze
  PAGE = /\A[0-9]{1,2}\Z/.freeze
  DEFAULT_LIMIT = 16
  DEFAULT_ORDER = { default: "ASC" }.freeze
  ALLOWED_ORDER_KEYS = %w[default published].freeze

  attr_reader :word, :order

  def word=(value)
    @word = value.to_s.strip[0, 50] # is 50 to much?
  end

  def order=(value)
    unless check_value?(value)
      @order = DEFAULT_ORDER
      return
    end

    hsh = if match_direction(value).blank?
            DEFAULT_ORDER
          else
            { fetch_key(value).to_s => match_direction(value).to_s }
          end

    @order = hsh
  end

  def page
    @page || build_page(DEFAULT_LIMIT)
  end

  def direction
    order.values.first || "ASC"
  end

  def page=(value)
    limit = if match_page(value).blank?
              DEFAULT_LIMIT
            else
              DEFAULT_LIMIT * value.to_i
            end

    @page = build_page(limit)
  end

  private

  def check_value?(value)
    value.is_a?(Hash) && ALLOWED_ORDER_KEYS.include?(fetch_key(value))
  end

  def match_direction(value)
    value.values.first.to_s.match(DIRECTION)
  end

  def match_page(value)
    value.to_s.match(PAGE)
  end

  def fetch_key(value)
    value.keys.first.to_s
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
