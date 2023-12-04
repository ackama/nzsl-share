class SignsExport
  include Rails.application.routes.url_helpers

  def initialize(signs)
    @signs = Sign.where(id: signs)
  end

  def to_csv
    CSV.generate do |csv|
      break if @signs.empty?

      csv << headers
      @signs.each do |sign|
        csv << csv_line(sign)
      end
    end
  end

  private

  def headers
    %w[
      video_url
      usage_example_urls
      illustration_urls
      word
      maori
      secondary
      description
      notes
      topic_names
    ]
  end

  def csv_line(sign)
    [
      url_for(sign.video),
      collate_blob_urls(sign.usage_examples),
      collate_blob_urls(sign.illustrations),
      sign.word,
      sign.maori,
      sign.secondary,
      sign.description,
      sign.notes,
      join_collection(sign.topics.map(&:name))
    ]
  end

  def collate_blob_urls(blobs)
    join_collection(blobs.map { |blob| url_for(blob) })
  end

  def join_collection(collection)
    collection.join("|")
  end
end
