# frozen_string_literal: true

module SQL
  module Status
    module_function

    def public_signs(order)
      <<-SQL.squish
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
              WHERE signs.status = 'published'
              UNION SELECT signs.id,
                          2 AS rank_precedence,
                          RANK() OVER (ORDER BY signs.word) AS rank_order
              FROM signs
              WHERE signs.status = 'published'
              UNION SELECT signs.id,
                          3 AS rank_precedence,
                          RANK() OVER (ORDER BY signs.secondary) AS rank_order
              FROM signs
              WHERE signs.status = 'published'
              UNION SELECT signs.id,
                          4 AS rank_precedence,
                          RANK() OVER (ORDER BY signs.secondary) AS rank_order
              FROM signs
              WHERE signs.status = 'published' ) AS rs1)
        SELECT signs.id
        FROM sign_search
        JOIN signs ON signs.id=sign_search.id
        LEFT JOIN LATERAL (SELECT sign_activities.sign_id,
                                  COUNT(sign_activities.sign_id) AS activity_count
                           FROM sign_activities
                           WHERE sign_search.row_num = 1 AND
                                 sign_activities.sign_id = sign_search.id AND
                                 sign_activities.key = 'agree'
                           GROUP BY sign_activities.sign_id) AS activity ON TRUE
        WHERE sign_search.row_num = 1
        ORDER BY #{order}
      SQL
    end
  end
end
