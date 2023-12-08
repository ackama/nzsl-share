class SignbankExport
  include Rails.application.routes.url_helpers
  class URLForbiddenCharacterError < StandardError; end

  SEPARATOR = "|".freeze
  QUERY = <<~SQL.squish.freeze
    SELECT
      array_to_string(array_agg(DISTINCT videos.id), '|') AS videos,
      array_to_string(array_agg(DISTINCT illustrations.id), '|') AS illustrations,
      array_to_string(array_agg(DISTINCT usage_examples.id), '|') AS usage_examples,
      signs.word,
      signs.maori,
      signs.secondary,
      signs.description,
      signs.notes,
      array_to_string(array_agg(DISTINCT topics.name), '|') AS topic_names
    FROM
      signs
      FULL OUTER JOIN sign_topics ON sign_topics.sign_id = signs.id
      FULL OUTER JOIN topics ON sign_topics.topic_id = topics.id
      FULL OUTER JOIN active_storage_attachments ON active_storage_attachments.record_id = signs.id AND active_storage_attachments.record_type = 'Sign'
      FULL OUTER JOIN active_storage_blobs AS videos ON active_storage_attachments.blob_id = videos.id AND active_storage_attachments.name = 'video'
      FULL OUTER JOIN active_storage_blobs AS illustrations ON active_storage_attachments.blob_id = illustrations.id AND active_storage_attachments.name = 'illustrations'
      FULL OUTER JOIN active_storage_blobs AS usage_examples ON active_storage_attachments.blob_id = usage_examples.id AND active_storage_attachments.name = 'usage_examples'
    WHERE
      status LIKE 'published'
    GROUP BY
      signs.id
    ORDER BY
      signs.id ASC;
  SQL

  def results
    @results ||= Sign.connection.execute(QUERY).to_a
  end

  def to_csv
    CSV.generate do |csv|
      break if results.empty?

      csv << results.first.keys # adds the attributes name on the first line
      results.each do |hash|
        hash = fetch_active_storage_urls(hash)
        csv << hash.values
      end
    end
  end

  private

  def fetch_active_storage_urls(hash)
    hash["videos"] = collate_blob_urls(hash["videos"])
    hash["illustrations"] = collate_blob_urls(hash["illustrations"])
    hash["usage_examples"] = collate_blob_urls(hash["usage_examples"])

    hash
  end

  def collate_blob_urls(id_string)
    ids = id_string.split(SEPARATOR)
    blobs = ActiveStorage::Blob.where(id: ids)
    join_collection(blobs.map { |blob| rails_blob_path(blob, expires_in: 7.days) })
  end

  def join_collection(collection)
    collection.join(SEPARATOR)
  end
end
