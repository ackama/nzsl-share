# frozen_string_literal: true

require "./lib/sql/search"

class SearchService < ApplicationService
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
    sql_arr = [SQL::Search.search(search_args), term: term]
    result_ids = parse_results(exec_query(sql_arr))
    result_relation = @relation.where(id: result_ids)
    search.total = result_relation.count
    fetch_results(result_relation, result_ids)
  end

  def parameterize_term
    search.term.split(" ").map { |s| s.parameterize(separator: "") }.join(" ")
  end

  def fetch_results(result_relation, result_ids)
    result_relation
      .limit(search.page[:limit])
      .order(Arel.sql("array_position(array[#{result_ids.join(",")}]::integer[], id)"))
  end

  def parse_results(results)
    results.field_values("id")
  end

  def exec_query(sql_arr)
    ApplicationRecord.connection.execute(ApplicationRecord.send(:sanitize_sql_array, sql_arr))
  end

  def search_args
    { order: search.order_clause }
  end
end
