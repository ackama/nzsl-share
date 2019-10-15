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
    signs = if search.order.blank?
              Sign.search_default_order(ids: ids)
            elsif search.order.key?("published")
              Sign.search_published_order(ids: ids, direction: search.direction)
            else
              Sign.search_default_order(ids: ids)
            end
    signs
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
        FROM signs
        JOIN sign_search
          ON signs.id = sign_search.sign_id
        ORDER BY #{order_by}
        LIMIT #{limit}
    SQL
  end

  def order_by
    order = if search.order.blank?
              "signs.english ASC"
            elsif search.order.key?("published")
              "signs.published_at #{search.order.values.first}"
            else
              "signs.english ASC"
            end

    ApplicationRecord.send(:sanitize_sql_for_order, order)
  end

  def limit
    search.page[:limit]
  end
end
