module SearchHelper
  def show_more_params(page)
    next_page_params(page, english: "ASC")
  end

  def show_asc_params(page)
    current_page_params(page, english: "ASC")
  end

  def show_desc_params(page)
    current_page_params(page, english: "DESC")
  end

  def published_asc_params(page)
    current_page_params(page, published: "ASC")
  end

  def published_desc_params(page)
    current_page_params(page, published: "DESC")
  end

  private

  def current_page_params(page, order)
    {
      page: page[:current_page],
      word: page[:word],
      total: page[:total],
      order: order
    }
  end

  def next_page_params(page, order)
    {
      page: page[:next_page],
      word: page[:word],
      total: page[:total],
      order: order
    }
  end
end
