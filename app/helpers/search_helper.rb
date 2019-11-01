module SearchHelper
  def show_more_params(page)
    next_page_params(page, params.fetch(:order, Search::DEFAULT_SORT))
  end

  def show_asc_params(page)
    current_page_params(page, :word_asc)
  end

  def show_desc_params(page)
    current_page_params(page, :word_desc)
  end

  def published_asc_params(page)
    current_page_params(page, :published_at_asc)
  end

  def published_desc_params(page)
    current_page_params(page, :published_at_desc)
  end

  private

  def current_page_params(page, order)
    {
      page: page[:current_page],
      word: page[:word],
      order: order
    }
  end

  def next_page_params(page, order)
    {
      page: page[:next_page],
      word: page[:word],
      order: order
    }
  end
end
