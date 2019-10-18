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
    search.total = fetch_total
    ids = exec_query(build_qry(SQL::Search.search(search_args))).values.flatten
    fetch_results(ids)
  end

  def fetch_results(ids)
    if published?
      Sign.search_published_order(ids: ids, direction: search.direction)
    else
      Sign.search_default_order(ids: ids, direction: search.direction)
    end
  end

  def fetch_total
    if search.new_word?
      exec_query(build_qry(SQL::Search.total)).values.flatten.first
    else
      search.total
    end
  end

  def build_qry(sql)
    search_word = search.word.parameterize(separator: "")
    [sql, "^#{search_word}", ".#{search_word}", "^#{search_word}", ".#{search_word}"]
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
              "signs.english #{search.direction}"
            end

    { order: ApplicationRecord.send(:sanitize_sql_for_order, order), limit: search.page[:limit] }
  end
end
