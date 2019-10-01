module SearchHelper
  def search_results(results)
    results.data
  end

  def search_results?(results)
    results.data.count > 1
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

  def published_params(support)
    {
      page: support[:this_page],
      word: support[:word],
      published: support[:next_pub]
    }
  end
end
