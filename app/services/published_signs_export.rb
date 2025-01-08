require "csv"

class PublishedSignsExport
  QUERY = <<~SQL.squish.freeze
    SELECT
      s.id,
      'https://www.nzslshare.nz/signs/' || s.id as url,
      s.word,
      u.username,
      u.email,
      s.created_at,
      count(DISTINCT saa.id) as agrees,
      count(DISTINCT sad.id) as disagrees
    FROM
      public.signs s
      inner join users u on s.contributor_id = u.id
      left join sign_activities saa on s.id = saa.sign_id
      and saa.key like 'agree'
      left join sign_activities sad on s.id = sad.sign_id
      and sad.key like 'disagree'
    where
      status like 'published'
    group by
      s.id,
      'https://www.nzslshare.nz/signs/' || s.id,
      s.word,
      u.username,
      u.email,
      s.created_at
    order by
      s.id asc;
  SQL

  def results
    @results ||= Sign.connection.execute(QUERY).to_a
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
