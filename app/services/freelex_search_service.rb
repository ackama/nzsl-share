# frozen_string_literal: true

require "./lib/sql/search"

class FreelexSearchService < SearchService
  def prepare_search(term)
    [SQL::Search.search_freelex(**search_args), { term: term }]
  end
end
