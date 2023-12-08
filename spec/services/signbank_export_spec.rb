require "rails_helper"

RSpec.describe SignbankExport, type: :service do
  include Rails.application.routes.url_helpers

  let!(:world) { SignbankExportWorld.new.setup }
  subject(:export) { described_class.new }

  describe ".results" do
    subject(:results) { export.results }

    it "includes the expected number of results" do
      expect(results.size).to eq 2 # Published signs, excludes unpublished sign
    end

    it "includes the expected data" do
      sign = world.published_signs.last

      # Add more topics and attachments to check sql query retrieves multiple values with a seperator as expected
      sign.update(topics: FactoryBot.create_list(:topic, 3))
      video_file = Rails.root.join("spec/fixtures/dummy.mp4").open
      video_file_io = { io: video_file, filename: File.basename(video_file) }
      sign.usage_examples.attach(video_file_io)
      image_file = Rails.root.join("spec/fixtures/image.jpeg").open
      image_file_io = { io: image_file, filename: File.basename(image_file) }
      sign.illustrations.attach(image_file_io)

      # Get last result and check fields
      result = results.last # ordered by ID asc
      expect(result).to eq({
        videos: sign.video.blob.id.to_s,
        usage_examples: sign.usage_examples.blobs.pluck(:id).join("|"),
        illustrations: sign.illustrations.blobs.pluck(:id).join("|"),
        word: sign.word,
        maori: sign.maori,
        secondary: sign.secondary,
        description: sign.description,
        notes: sign.notes,
        topic_names: sign.topics.pluck(:name).join("|")
      }.stringify_keys)
    end
  end

  describe ".to_csv" do
    subject(:csv) { export.to_csv }

    it "builds the expected CSV structure" do
      lines = csv.split("\n")
      expect(lines.first).to eq(
        "videos,illustrations,usage_examples,word,maori,secondary,description,notes,topic_names"
      )
      expect(lines.size).to eq 3 # Headers plus 2 included signs
    end

    it "includes the expected data" do
      expect(csv).to include(world.published_signs[0].word)
      expect(csv).to include(world.published_signs[1].word)
      expect(csv).not_to include(world.unpublished_sign.word)
    end

    it "turns the video id into a signed url" do
      video_url = csv.split("\n").last.split(",").first
      expect(video_url).to start_with("/rails/active_storage/blobs/redirect/")
      expect(video_url).to end_with("dummy.mp4")
    end

    it "turns the illustration ids into signed urls with a separator" do
      image_file = Rails.root.join("spec/fixtures/image.jpeg").open
      image_file_io = { io: image_file, filename: File.basename(image_file) }
      world.published_signs.last.usage_examples.attach(image_file_io)
      illustration_urls = csv.split("\n").last.split(",").second.split("|")

      illustration_urls.each do |url|
        expect(url).to start_with("/rails/active_storage/blobs/redirect/")
        expect(url).to end_with("image.jpeg")
      end
    end

    it "turns the usage example ids into signed urls with a separator" do
      video_file = Rails.root.join("spec/fixtures/dummy.mp4").open
      video_file_io = { io: video_file, filename: File.basename(video_file) }
      world.published_signs.last.usage_examples.attach(video_file_io)
      usage_example_urls = csv.split("\n").last.split(",").third.split("|")

      usage_example_urls.each do |url|
        expect(url).to start_with("/rails/active_storage/blobs/redirect/")
        expect(url).to end_with("dummy.mp4")
      end
    end
  end
end

class SignbankExportWorld
  attr_reader :published_signs, :unpublished_sign

  def setup
    @published_signs = FactoryBot.create_list(
      :sign, 2, :published, :processed, :with_illustrations, :with_usage_examples, :with_additional_info
    )
    @unpublished_sign = FactoryBot.create(:sign)

    self
  end
end
