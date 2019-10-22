# frozen_string_literal: true

module SQL
  module Search
    module_function

    def search(args)
      <<-SQL
        WITH
        sign_search(ids, total)
        AS
        (
          SELECT
            ARRAY_AGG(rs1.id::INT),
            ARRAY_LENGTH(ARRAY_AGG(rs1.id::INT), 1)
            FROM
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
            ) AS rs1
        )
        SELECT
          ARRAY_AGG(rs2.id::INT) AS ids,
          rs2.total
          FROM
	        (
            SELECT
              signs.id,
              sign_search.total
              FROM signs
              JOIN sign_search
                ON signs.id = ANY(sign_search.ids)
              ORDER BY #{args[:order]}
              LIMIT #{args[:limit]}
          ) AS rs2
          GROUP BY rs2.total
      SQL
    end
  end
end
