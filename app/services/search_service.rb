# frozen_string_literal: true

require "./lib/sql/search"

class SearchService < ApplicationService
  attr_reader :search, :results

  def initialize(params)
    @search = params[:search]
    @scope = params[:scope]
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
    sql_arr = [SQL::Search.search(search_args), term, term, term, term]
    results = parse_results(exec_query(sql_arr).first)
    search.total = results[0]
    fetch_results(results[1])
  end

  def parameterize_term
    search.term.split(" ").map { |s| s.parameterize(separator: "") }.join(" ")
  end

  def fetch_results(ids)
    Sign.for_cards.where(id: ids).sort_by { |sign| ids.index(sign.id) }
  end

  def parse_results(results)
    return [0, []] if results.blank? || results["ids"].blank?

    ids = results["ids"].tr("{}", "").split(",").map(&:to_i)
    total = results["total"].to_i
    [total, ids]
  end

  def exec_query(sql_arr)
    ApplicationRecord.connection.execute(ApplicationRecord.send(:sanitize_sql_array, sql_arr))
  end

  def search_args
    {
      order: search.order_clause,
      limit: search.page[:limit],
      where: @scope
    }
  end
end
