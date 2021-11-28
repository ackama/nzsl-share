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
    result_ids = parse_results(exec_query(sql_arr))
    result_relation = @relation.where(@relation.primary_key => result_ids)
    search.total = result_relation.count
    fetch_results(result_relation, result_ids)
  end

  def parameterize_term
    search.term.split.map { |s| s.parameterize(separator: "") }.join(" ")
  end

  def fetch_results(result_relation, result_ids)
    result_relation
      .limit(search.page[:limit])
      .order(Arel.sql("array_position(array[#{result_ids.join(",")}]::integer[],
                       \"#{@relation.table_name}\".\"#{@relation.primary_key}\")"))
  end

  def parse_results(results)
    results.field_values(@relation.primary_key)
  end

  def exec_query(sql_arr)
    ApplicationRecord.connection.execute(ApplicationRecord.send(:sanitize_sql_array, sql_arr))
  end

  def search_args
    { order: search.order_clause }
  end

  def prepare_search(term)
    [SQL::Search.search(**search_args), { term: term }]
  end
end
