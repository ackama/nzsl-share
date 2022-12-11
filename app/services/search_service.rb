# frozen_string_literal: true

class SearchService
  SEARCH_SQL = <<-SQL.squish
    WITH sign_search(id, rank_precedence, rank_order, row_num) AS
      (SELECT rs1.id,
              rs1.rank_precedence,
              rs1.rank_order,
              ROW_NUMBER() OVER (PARTITION BY rs1.id
                                ORDER BY rs1.rank_precedence ASC) AS row_num
      FROM
        (SELECT ranked_signs_by_exact_gloss.id,
                1 AS rank_precedence,
                RANK() OVER (ORDER BY ranked_signs_by_exact_gloss.word) AS rank_order
          FROM signs ranked_signs_by_exact_gloss
          WHERE UNACCENT(ranked_signs_by_exact_gloss.word) = :term
          UNION SELECT ranked_signs_by_matched_gloss.id,
                      2 AS rank_precedence,
                      RANK() OVER (ORDER BY ranked_signs_by_matched_gloss.word) AS rank_order
          FROM signs ranked_signs_by_matched_gloss
          WHERE UNACCENT(ranked_signs_by_matched_gloss.word) ~* :term
          UNION SELECT ranked_signs_by_exact_secondary.id,
                      3 AS rank_precedence,
                      RANK() OVER (ORDER BY ranked_signs_by_exact_secondary.secondary) AS rank_order
          FROM signs ranked_signs_by_exact_secondary
          WHERE UNACCENT(ranked_signs_by_exact_secondary.secondary) = :term
          UNION SELECT ranked_signs_by_matched_secondary.id,
                      4 AS rank_precedence,
                      RANK() OVER (ORDER BY ranked_signs_by_matched_secondary.secondary) AS rank_order
          FROM signs ranked_signs_by_matched_secondary
          WHERE UNACCENT(ranked_signs_by_matched_secondary.secondary) ~* :term ) AS rs1)
    SELECT *, activity.count AS activity_count
    FROM sign_search
    LEFT JOIN LATERAL (SELECT sign_activities.sign_id,
                              COUNT(sign_activities.sign_id) AS count
                      FROM sign_activities
                      WHERE sign_search.row_num = 1 AND
                            sign_activities.sign_id = sign_search.id AND
                            sign_activities.key = 'agree'
                      GROUP BY sign_activities.sign_id) AS activity ON TRUE
    WHERE sign_search.row_num = 1
  SQL

  attr_reader :search, :results

  def initialize(search:, relation:)
    @search = search
    @relation = relation
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
    sql_arr = prepare_search(term)
    results = exec_query(sql_arr)
    search.total = results.count

    results.limit(search.page[:limit])
  end

  def parameterize_term
    search.term.split.map { |s| s.parameterize(separator: "") }.join(" ")
  end

  def exec_query(sql_arr)
    model_class = @relation.model
    @relation.joins("
      INNER JOIN (#{model_class.sanitize_sql_array(sql_arr)}) search_results
      ON search_results.id=#{model_class.table_name}.#{model_class.primary_key}
    ").order(prepare_order)
  end

  def prepare_order
    Arel.sql(search.order_clause)
  end

  def prepare_search(term)
    [self.class::SEARCH_SQL, { term: term }]
  end
end
