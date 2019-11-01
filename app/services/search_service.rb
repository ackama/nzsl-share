# frozen_string_literal: true

require "./lib/sql/search"

class SearchService < ApplicationService
  attr_reader :search, :results

  def initialize(params)
    @search = params[:search]
    @results = ApplicationService.new_results
  end

  def process
    results.data = build_results
    results.support = search.page_with_total
    results
  end

  private

  def build_results
    word = search.word.parameterize(separator: "")
    sql_arr = [SQL::Search.search(search_args), "^#{word}", ".#{word}", "^#{word}", ".#{word}"]
    results = parse_results(exec_query(sql_arr).first)
    search.total = results[0]
    fetch_results(results[1])
  end

  def fetch_results(ids)
    Sign.where(id: ids).order(search_args[:order])
  end

  def parse_results(results)
    return [0, []] if results.blank?

    ids = results["ids"].tr("{}", "").split(",").map(&:to_i)
    total = results["total"].to_i
    [total, ids]
  end

  def exec_query(sql_arr)
    ApplicationRecord.connection.execute(ApplicationRecord.send(:sanitize_sql_array, sql_arr))
  end

  def search_args
    {
      order: ApplicationRecord.send(:sanitize_sql_for_order, search.order),
      limit: search.page[:limit]
    }
  end
end
