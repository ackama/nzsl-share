# frozen_string_literal: true

module SQL
  module Search
    module_function

    def search(args)
      <<-SQL
        WITH
        sign_search(sign_id)
        AS
        (
          #{union}
        )
        SELECT
          sign_id
          FROM signs
          JOIN sign_search
            ON signs.id = sign_search.sign_id
          ORDER BY #{args[:order]}
          LIMIT #{args[:limit]}
      SQL
    end

    def total
      <<-SQL
        WITH
        sign_search(sign_id)
        AS
        (
          #{union}
        )
        SELECT
          COUNT(*)
          FROM sign_search
      SQL
    end

    def union
      <<-SQL
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
      SQL
    end
  end
end
