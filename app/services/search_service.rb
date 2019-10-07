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
          WHERE UNACCENT(signs.english)  ~* ?
        UNION ALL
        SELECT
          signs.id,
          2,
          RANK() OVER (ORDER BY signs.english)
          FROM signs
          WHERE UNACCENT(signs.english) ~* ?
        UNION ALL
        SELECT
          signs.id,
          3,
          RANK() OVER (ORDER BY signs.secondary)
          FROM signs
          WHERE UNACCENT(signs.secondary) ~* ?
        UNION ALL
        SELECT
          signs.id,
          4,
          RANK() OVER (ORDER BY signs.secondary)
          FROM signs
          WHERE UNACCENT(signs.secondary) ~* ?
      )
      SELECT                          -- problems with dupes but can fix with relevance
        signs.english,
        signs.secondary,
        signs.maori,
        'nzsl dev user' AS user_name, -- temp user
        '256' AS agree,               -- temp agree int will come from signs
        '512' AS disagree,            -- temp disagree int will come from signs
        TO_CHAR(signs.published_at:: DATE, 'Mon dd yyyy') AS nice_published_at
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
              "signs.secondary ASC" # place holder until we can include relevance
            end

    ApplicationRecord.send(:sanitize_sql_for_order, order)
  end

  def limit
    search.page[:limit]
  end
end
