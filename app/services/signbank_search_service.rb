# frozen_string_literal: true

class SignbankSearchService < SearchService
  SEARCH_SQL = <<-SQL.squish
    WITH sign_search(id, rank_precedence, rank_order, row_num) AS
      (SELECT rs1.id,
              rs1.rank_precedence,
              rs1.rank_order,
              ROW_NUMBER() OVER (PARTITION BY rs1.id
                                ORDER BY rs1.rank_precedence ASC) AS row_num
      FROM
        (SELECT words.id,
                1 AS rank_precedence,
                RANK() OVER (ORDER BY words.gloss) AS rank_order
          FROM words
          WHERE words.gloss_normalized = :term
          UNION SELECT words.id,
                      2 AS rank_precedence,
                      RANK() OVER (ORDER BY words.gloss) AS rank_order
          FROM words
          WHERE words.gloss_normalized LIKE :like_term
          UNION SELECT words.id,
                      3 AS rank_precedence,
                      RANK() OVER (ORDER BY words.minor) AS rank_order
          FROM words
          WHERE words.minor_normalized = :term
          UNION SELECT words.id,
                      4 AS rank_precedence,
                      RANK() OVER (ORDER BY words.minor) AS rank_order
          FROM words
          WHERE words.minor_normalized LIKE :like_term ) AS rs1)
    SELECT *
    FROM sign_search
    WHERE sign_search.row_num = 1
  SQL

  def prepare_search(term)
    [
      SEARCH_SQL,
      { term: term, like_term: "%#{DictionarySign.sanitize_sql_like(term)}%" }
    ]
  end
end
