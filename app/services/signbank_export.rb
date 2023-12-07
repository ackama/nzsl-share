class SignbankExport
  include Rails.application.routes.url_helpers
  class URLForbiddenCharacterError < StandardError; end

  SEPARATOR = "|".freeze
  QUERY = <<~SQL.squish.freeze
    SELECT
      array_to_string(array_agg(distinct videos.id), '|') as videos,
      array_to_string(array_agg(distinct illustrations.id), '|') as illustrations,
      array_to_string(array_agg(distinct usage_examples.id), '|') as usage_examples,
      signs.word,
      signs.maori,
      signs.secondary,
      signs.description,
      signs.notes,
      array_to_string(array_agg(distinct topics.name), '|') as topic_names
    FROM
      signs
      FULL OUTER JOIN sign_topics on sign_topics.sign_id = signs.id
      FULL OUTER JOIN topics on sign_topics.topic_id = topics.id
      FULL OUTER JOIN active_storage_attachments on active_storage_attachments.record_id = signs.id and active_storage_attachments.record_type = 'Sign'
      FULL OUTER JOIN active_storage_blobs as videos on active_storage_attachments.blob_id = videos.id and active_storage_attachments.name = 'video'
      FULL OUTER JOIN active_storage_blobs as illustrations on active_storage_attachments.blob_id = illustrations.id and active_storage_attachments.name = 'illustrations'
      FULL OUTER JOIN active_storage_blobs as usage_examples on active_storage_attachments.blob_id = usage_examples.id and active_storage_attachments.name = 'usage_examples'
    where
      status like 'published'
    group by
      signs.id
    order by
      signs.id asc;
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
    urls = blobs.map { |blob| rails_blob_path(blob, expires_in: 7.days) }
    # This shouldn't happen, main place this could be injected in is filenames but those aren't allowed to have | chars
    # Still, to be better safe than sorry, this will cause the export to fail if a separator does get into a url somehow
    urls.each do |url|
      fail URLForbiddenCharacterError("Forbidden Character #{SEPARATOR} in #{url}") if url.include?(SEPARATOR)
    end

    join_collection(urls)
  end

  def join_collection(collection)
    collection.map { |item| item.gsub(SEPARATOR, "") }.join(SEPARATOR)
  end
end
