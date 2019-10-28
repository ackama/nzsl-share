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
    if published?
      Sign.search_published_order(ids: ids, direction: search.direction)
    else
      Sign.search_default_order(ids: ids, direction: search.direction)
    end
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

  def published?
    search.order_name == "published"
  end

  def search_args
    order = if published?
              "signs.published_at #{search.direction}"
            else
              "signs.word #{search.direction}"
            end

    { order: ApplicationRecord.send(:sanitize_sql_for_order, order), limit: search.page[:limit] }
  end
end
