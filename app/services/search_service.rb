# frozen_string_literal: true

class SearchService < ApplicationService
  attr_reader :search, :results

  def initialize(params)
    @search = params[:search]
    @results = ApplicationService.new_results
  end

  def process
    results.data = build_results
    results.support = search.page
    results
  end

  private

  def build_results
    search_word = search.word.parameterize(separator: "")
    sql_arr = [search_sql, "^#{search_word}", ".#{search_word}", "^#{search_word}", ".#{search_word}"]
    ids = exec_query(sql_arr).values.flatten
    fetch_results(ids)
  end

  def fetch_results(ids)
    limit = search.page[:limit]

    signs = if search.order.blank?
              default_order(ids, limit)
            elsif search.order.key?("published")
              published_order(ids, limit)
            else
              default_order(ids, limit)
            end
    signs
  end

  def default_order(ids, limit)
    Sign.search(ids).default_order.search_limit(limit)
  end

  def published_order(ids, limit)
    Sign.search(ids).published_order(search.direction).search_limit(limit)
  end

  def exec_query(sql_arr)
    ApplicationRecord.connection.execute(ApplicationRecord.send(:sanitize_sql_array, sql_arr))
  end

  def search_sql
    <<-SQL
      WITH
      sign_search(sign_id)
      AS
      (
        SELECT
          signs.id
          FROM signs
          WHERE UNACCENT(signs.english)  ~* ?
        UNION
        SELECT
          signs.id
          FROM signs
          WHERE UNACCENT(signs.english) ~* ?
        UNION
        SELECT
          signs.id
          FROM signs
          WHERE UNACCENT(signs.secondary) ~* ?
        UNION
        SELECT
          signs.id
          FROM signs
          WHERE UNACCENT(signs.secondary) ~* ?
      )
      SELECT
        sign_id
        FROM sign_search
    SQL
  end
end
