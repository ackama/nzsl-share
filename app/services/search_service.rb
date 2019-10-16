# frozen_string_literal: true

class SearchService < ApplicationService
  DEFAULT_ORDER = "signs.english ASC"
  PUBLISHED_ORDER = "signs.published_at"

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
    ids = exec_query(build_qry(search_sql)).values.flatten
    fetch_results(ids)
  end

  def fetch_results(ids)
    if search.order.blank?
      Sign.search_default_order(ids: ids)
    elsif search.order.key?("published")
      Sign.search_published_order(ids: ids, direction: search.direction)
    else
      Sign.search_default_order(ids: ids)
    end
  end

  def fetch_total
    if search.new_search?
      exec_query(build_qry(search_total_sql)).values.flatten.first
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

  def search_sql
    <<-SQL
      #{search_str}
      SELECT
        sign_id
        FROM signs
        JOIN sign_search
          ON signs.id = sign_search.sign_id
        ORDER BY #{order_by}
        LIMIT #{limit}
    SQL
  end

  def search_total_sql
    <<-SQL
      #{search_str}
      SELECT
        COUNT(*)
        FROM sign_search
    SQL
  end

  def search_str
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
    SQL
  end

  def order_by
    order = if search.order.blank?
              DEFAULT_ORDER
            elsif search.order.key?("published")
              "#{PUBLISHED_ORDER} #{search.order.values.first}"
            else
              DEFAULT_ORDER
            end

    ApplicationRecord.send(:sanitize_sql_for_order, order)
  end

  def limit
    search.page[:limit]
  end
end
