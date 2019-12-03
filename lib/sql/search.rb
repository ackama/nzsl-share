# frozen_string_literal: true

module SQL
  module Search
    module_function

    def search_freelex(order:)
      <<-SQL
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
        SELECT freelex_signs.headword_id
        FROM sign_search
        JOIN freelex_signs ON freelex_signs.headword_id=sign_search.id
        WHERE sign_search.row_num = 1
        ORDER BY #{order}
      SQL
    end

    def search(order:)
      <<-SQL
        WITH sign_search(id, rank_precedence, rank_order, row_num) AS
          (SELECT rs1.id,
                  rs1.rank_precedence,
                  rs1.rank_order,
                  ROW_NUMBER() OVER (PARTITION BY rs1.id
                                    ORDER BY rs1.rank_precedence ASC) AS row_num
          FROM
            (SELECT signs.id,
                    1 AS rank_precedence,
                    RANK() OVER (ORDER BY signs.word) AS rank_order
              FROM signs
              WHERE UNACCENT(signs.word) = :term
              UNION SELECT signs.id,
                          2 AS rank_precedence,
                          RANK() OVER (ORDER BY signs.word) AS rank_order
              FROM signs
              WHERE UNACCENT(signs.word) ~* :term
              UNION SELECT signs.id,
                          3 AS rank_precedence,
                          RANK() OVER (ORDER BY signs.secondary) AS rank_order
              FROM signs
              WHERE UNACCENT(signs.secondary) = :term
              UNION SELECT signs.id,
                          4 AS rank_precedence,
                          RANK() OVER (ORDER BY signs.secondary) AS rank_order
              FROM signs
              WHERE UNACCENT(signs.secondary) ~* :term ) AS rs1)
        SELECT signs.id
        FROM sign_search
        JOIN signs ON signs.id=sign_search.id
        WHERE sign_search.row_num = 1
        ORDER BY #{order}
      SQL
    end
  end
end
