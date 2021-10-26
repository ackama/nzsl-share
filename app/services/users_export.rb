class UsersExport
  QUERY = <<~SQL.freeze
    SELECT
      u.username,
      u.email,
      count(s.id) AS number_of_signs,
      CASE
        WHEN u.administrator = false
        AND u."validator" = false
        AND u.moderator = false
        AND u.approved = false THEN 'Basic'
        ELSE array_to_string(
          string_to_array(
            trim(
              CASE
                WHEN u.administrator THEN 'Admin '
                ELSE ''
              END || CASE
                WHEN u."validator" THEN 'Validator '
                ELSE ''
              end || CASE
                WHEN u.moderator THEN 'Moderator '
                ELSE ''
              end || CASE
                WHEN u.approved THEN 'Approved '
                ELSE ''
              end
            ),
            ' '
          ),
          ','
        )
      END AS roles
    FROM
      users u
      LEFT JOIN signs s ON u.id = s.contributor_id
    GROUP BY
      u.username,
      u.email,
      u.administrator,
      u."validator",
      u.moderator,
      u.approved
    ORDER BY
      u.username ASC;
  SQL

  def results
    @results ||= User.connection.execute(QUERY).to_a
  end

  def to_csv
    CSV.generate do |csv|
      break if results.empty?

      csv << results.first.keys # adds the attributes name on the first line
      results.each do |hash|
        csv << hash.values
      end
    end
  end
end
