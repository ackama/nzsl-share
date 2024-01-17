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
      expect(result).to include({
        videos: sign.video.blob.id.to_s,
        usage_examples: sign.usage_examples.blobs.pluck(:id).sort.join("|"),
        illustrations: sign.illustrations.blobs.pluck(:id).sort.join("|"),
        word: sign.word,
        maori: sign.maori,
        secondary: sign.secondary,
        notes: sign.notes,
        topic_names: sign.topics.order(:id).pluck(:name).sort.join("|"),
        contributor_email: sign.contributor.email,
        contributor_username: sign.contributor.username,
        agrees: sign.agree_count,
        disagrees: sign.disagree_count,
        sign_comments: sign.sign_comments.where(display: true).where(removed: false).map do |comment|
                         "#{comment.anonymous ? "Anonymous" : comment.user.username}: #{comment.comment}"
                       end.sort.join("|")
      }.stringify_keys)
      expect(result["created_at"].beginning_of_hour).to eq(sign.created_at.beginning_of_hour)
    end

    it "includes expected sign comments but not unexpected ones" do
      result = results.last
      published_comment = world.published_comment
      anonymous_comment = world.anonymous_comment
      invisible_comment = world.invisible_comment
      deleted_comment = world.deleted_comment
      expect(result["sign_comments"]).to include("#{published_comment.user.username}: #{published_comment.comment}")
      expect(result["sign_comments"]).to include("Anonymous: #{anonymous_comment.comment}")
      expect(result["sign_comments"]).not_to include("#{anonymous_comment.user.username}: #{anonymous_comment.comment}")
      expect(result["sign_comments"]).not_to include("#{invisible_comment.user.username}: #{invisible_comment.comment}")
      expect(result["sign_comments"]).not_to include("#{deleted_comment.user.username}: #{deleted_comment.comment}")
    end
  end

  describe ".to_csv" do
    subject(:csv) { export.to_csv }

    it "builds the expected CSV structure" do
      lines = csv.split("\n")
      expect(lines.first).to eq(
        "word,maori,secondary,notes,created_at,contributor_email,contributor_username,agrees," \
        "disagrees,topic_names,videos,illustrations,usage_examples,sign_comments"
      )
      expect(lines.size).to eq 3 # Headers plus 2 included signs
    end

    it "includes the expected data" do
      expect(csv).to include(world.published_signs[0].word)
      expect(csv).to include(world.published_signs[1].word)
      expect(csv).not_to include(world.unpublished_sign.word)
    end

    it "turns the video id into a signed url" do
      video_url = csv.split("\n").last.split(",")[-4]
      expect(video_url).to start_with("/rails/active_storage/blobs/redirect/")
      expect(video_url).to end_with("dummy.mp4")
    end

    it "turns the illustration ids into signed urls with a separator" do
      image_file = Rails.root.join("spec/fixtures/image.jpeg").open
      image_file_io = { io: image_file, filename: File.basename(image_file) }
      world.published_signs.last.usage_examples.attach(image_file_io)
      illustration_urls = csv.split("\n").last.split(",")[-3].split("|")

      illustration_urls.each do |url|
        expect(url).to start_with("/rails/active_storage/blobs/redirect/")
        expect(url).to end_with("image.jpeg")
      end
    end

    it "turns the usage example ids into signed urls with a separator" do
      video_file = Rails.root.join("spec/fixtures/dummy.mp4").open
      video_file_io = { io: video_file, filename: File.basename(video_file) }
      world.published_signs.last.usage_examples.attach(video_file_io)
      usage_example_urls = csv.split("\n").last.split(",")[-2].split("|")

      usage_example_urls.each do |url|
        expect(url).to start_with("/rails/active_storage/blobs/redirect/")
        expect(url).to end_with("dummy.mp4")
      end
    end
  end
end

class SignbankExportWorld
  attr_reader :published_signs, :unpublished_sign, :published_comment, :deleted_comment, :invisible_comment,
              :anonymous_comment

  def setup
    @published_signs = FactoryBot.create_list(
      :sign, 2, :published, :processed, :with_illustrations, :with_usage_examples, :with_additional_info
    )
    @unpublished_sign = FactoryBot.create(:sign)
    @published_comment = FactoryBot.create(:sign_comment, sign: @published_signs.second)
    @deleted_comment = FactoryBot.create(:sign_comment, sign: @published_signs.second, removed: true)
    @invisible_comment = FactoryBot.create(:sign_comment, sign: @published_signs.second, display: false)
    @anonymous_comment = FactoryBot.create(:sign_comment, sign: @published_signs.second, anonymous: true)
    FactoryBot.create_list(:sign_activity, 5, sign: @published_signs.second)

    self
  end
end
