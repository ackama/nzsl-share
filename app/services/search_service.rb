# frozen_string_literal: true

require "./lib/sql/search"

class SearchService
  attr_reader :search, :results

  def initialize(search:, relation:)
    @search = search
    @relation = relation
    @results = new_results
  end

  def process
    results.data = build_results
    results.support = search.page_with_total
    results
  end

  private

  def new_results
    SearchResults.new
  end

  def build_results
    term = parameterize_term
    sql_arr = prepare_search(term)
    results = exec_query(sql_arr)
    search.total = results.count

    results.limit(search.page[:limit])
  end

  def parameterize_term
    search.term.split.map { |s| s.parameterize(separator: "") }.join(" ")
  end

  def exec_query(sql_arr)
    model_class = @relation.model
    @relation.joins("
      INNER JOIN (#{model_class.sanitize_sql_array(sql_arr)}) search_results
      ON search_results.id=#{model_class.table_name}.#{model_class.primary_key}
    ").order(prepare_order)
  end

  def prepare_order
    Arel.sql(search.order_clause)
  end

  def prepare_search(term)
    [SQL::Search.search(**search_args), { term: term }]
  end
end
