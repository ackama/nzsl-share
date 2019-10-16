module SearchHelper
  def default_params(page)
    {
      page: page[:next_page],
      word: page[:word],
      total: page[:total]
    }
  end

  def published_asc_params(page)
    published_params(page, "ASC")
  end

  def published_desc_params(page)
    published_params(page, "DESC")
  end

  private

  def published_params(page, direction)
    {
      page: page[:current_page],
      word: page[:word],
      total: page[:total],
      order: { published: direction }
    }
  end
end
