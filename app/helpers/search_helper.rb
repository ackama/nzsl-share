module SearchHelper
  def search_results(results)
    results.data
  end

  def search_results?(results)
    results.data.any?
  end

  def search_count(results)
    results.data.count
  end

  def search_word(results)
    results.support[:word]
  end

  def show_more?(results)
    results.data.count < results.support[:limit]
  end

  def default_params(support)
    {
      page: support[:next_page],
      word: support[:word]
    }
  end

  def published_asc_params(support)
    published_params(support, "ASC")
  end

  def published_desc_params(support)
    published_params(support, "DESC")
  end

  private

  def published_params(support, direction)
    {
      page: support[:current_page],
      word: support[:word],
      order: { published: direction }
    }
  end
end
