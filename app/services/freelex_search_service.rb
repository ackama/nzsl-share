# frozen_string_literal: true

class FreelexSearchService < SearchService
  SEARCH_SQL = <<-SQL.squish
    WITH sign_search(id, rank_precedence, rank_order, row_num) AS
      (SELECT rs1.id,
              rs1.rank_precedence,
              rs1.rank_order,
              ROW_NUMBER() OVER (PARTITION BY rs1.id
                                ORDER BY rs1.rank_precedence ASC) AS row_num
      FROM
        (SELECT freelex_signs.headword_id AS id,
                1 AS rank_precedence,
                RANK() OVER (ORDER BY freelex_signs.word) AS rank_order
          FROM freelex_signs
          WHERE UNACCENT(freelex_signs.word) = :term
          UNION SELECT freelex_signs.headword_id AS id,
                      2 AS rank_precedence,
                      RANK() OVER (ORDER BY freelex_signs.word) AS rank_order
          FROM freelex_signs
          WHERE UNACCENT(freelex_signs.word) ~* :term
          UNION SELECT freelex_signs.headword_id AS id,
                      3 AS rank_precedence,
                      RANK() OVER (ORDER BY freelex_signs.secondary) AS rank_order
          FROM freelex_signs
          WHERE UNACCENT(freelex_signs.secondary) = :term
          UNION SELECT freelex_signs.headword_id AS id,
                      4 AS rank_precedence,
                      RANK() OVER (ORDER BY freelex_signs.secondary) AS rank_order
          FROM freelex_signs
          WHERE UNACCENT(freelex_signs.secondary) ~* :term ) AS rs1)
    SELECT *
    FROM sign_search
    WHERE sign_search.row_num = 1
  SQL
end
