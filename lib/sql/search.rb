# frozen_string_literal: true

module SQL
  module Search
    module_function

    def search(args)
      <<-SQL
        WITH
        sign_search(id, rank_precedence, rank_order, row_num)
        AS
        (
          SELECT
            rs1.id,
            rs1.rank_precedence,
	          rs1.rank_order,
            ROW_NUMBER() OVER (PARTITION BY rs1.id ORDER BY rs1.rank_precedence ASC) AS row_num
            FROM
            (
              SELECT
                signs.id,
                1 AS rank_precedence,
                RANK() OVER (ORDER BY signs.word) AS rank_order
                FROM signs
                WHERE UNACCENT(signs.word) = ?
              UNION
              SELECT
                signs.id,
                2 AS rank_precedence,
                RANK() OVER (ORDER BY signs.word) AS rank_order
                FROM signs
                WHERE UNACCENT(signs.word) ~* ?
              UNION
              SELECT
                signs.id,
                3 AS rank_precedence,
                RANK() OVER (ORDER BY signs.secondary) AS rank_order
                FROM signs
                WHERE UNACCENT(signs.secondary) = ?
              UNION
              SELECT
                signs.id,
                4 AS rank_precedence,
                RANK() OVER (ORDER BY signs.secondary) AS rank_order
                FROM signs
                WHERE UNACCENT(signs.secondary) ~* ?
            ) AS rs1
        )
        SELECT
          ARRAY_AGG(rs2.id::INT) AS ids,
          (SELECT COUNT(sign_search.row_num) FROM sign_search WHERE sign_search.row_num = 1) AS total
          FROM
	        (
            SELECT
              signs.id
              FROM signs
              JOIN sign_search
                ON signs.id = sign_search.id
              WHERE sign_search.row_num = 1
                AND signs.id IN (#{args[:where].join(", ")})
              ORDER BY #{args[:order]}
              LIMIT #{args[:limit]}
          ) AS rs2
      SQL
    end
  end
end
