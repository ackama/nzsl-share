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
            ARRAY_AGG(rs.id::INT),
            ARRAY_LENGTH(ARRAY_AGG(rs.id::INT), 1) AS total
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
            ) AS rs
        ),
        sign_order_limit(ids, total)
        AS
        (
          SELECT
            signs.id,
            sign_search.total
            FROM signs
            JOIN sign_search
              ON signs.id = ANY(sign_search.ids)
            ORDER BY #{args[:order]}
            LIMIT #{args[:limit]}
        )
        SELECT
          ARRAY_AGG(sign_order_limit.ids::INT) AS ids,
          sign_order_limit.total
          FROM sign_order_limit
          GROUP BY sign_order_limit.total
      SQL
    end
  end
end
