# frozen_string_literal: true

class SearchService < ApplicationService
  attr_reader :search, :results

  def initialize(params)
    @search = params[:search]
    @results = ApplicationService.new_results
  end

  def process
    results.data = build_results
    results
  end

  private

  def build_results
    sql_arr = [search_sql, "^#{search.word}", ".#{search.word}", "^#{search.word}", ".#{search.word}"]
    result = exec_query(sql_arr).to_json
    JSON(result)
  end

  def exec_query(sql_arr)
    ApplicationRecord.connection.execute(ApplicationRecord.send(:sanitize_sql_array, sql_arr))
  end

  def search_sql
    <<-SQL
      WITH
      sign_search(sign_id, query_rank, word_rank)
      AS
      (
        SELECT
          signs.id,
          1,
          RANK() OVER (ORDER BY signs.english)
          FROM signs
          WHERE signs.english  ~* ?
        UNION ALL
        SELECT
          signs.id,
          2,
          RANK() OVER (ORDER BY signs.english)
          FROM signs
          WHERE signs.english ~* ?
        UNION ALL
        SELECT
          signs.id,
          3,
          RANK() OVER (ORDER BY signs.secondary)
          FROM signs
          WHERE signs.secondary ~* ?
        UNION ALL
        SELECT
          signs.id,
          4,
          RANK() OVER (ORDER BY signs.secondary)
          FROM signs
          WHERE signs.secondary ~* ?
      )
      SELECT
        signs.id,
        signs.english,
        signs.maori,
        signs.secondary,
        signs.published_at,
        TO_CHAR(signs.published_at:: DATE, 'Mon dd yyyy') AS nice_published_at
        FROM signs
        JOIN sign_search
          ON signs.id = sign_search.sign_id
        ORDER BY #{order_by}
    SQL
  end

  def order_by
    order = if search.published
              "signs.published_at #{search.published}"
            else
              "signs.english"
            end

    ApplicationRecord.send(:sanitize_sql_for_order, order)
  end
end
