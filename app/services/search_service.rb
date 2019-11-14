# frozen_string_literal: true

require "./lib/sql/search"

class SearchService < ApplicationService
  attr_reader :search, :results

  def initialize(params)
    @search = params[:search]
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
    count, ids = parse_results(exec_query(sql_arr))
    search.total = count
    fetch_results(ids)
  end

  def parameterize_term
    search.term.split(" ").map { |s| s.parameterize(separator: "") }.join(" ")
  end

  def fetch_results(ids)
    Sign.for_cards.where(id: ids).sort_by { |sign| ids.index(sign.id) }
  end

  def parse_results(results)
    [results.count, results.field_values("id")]
  end

  def exec_query(sql_arr)
    ApplicationRecord.connection.execute(ApplicationRecord.send(:sanitize_sql_array, sql_arr))
  end

  def search_args
    { order: search.order_clause }
  end
end
