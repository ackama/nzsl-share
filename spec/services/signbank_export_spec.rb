require "rails_helper"

RSpec.describe SignbankExport, type: :service do
  include Rails.application.routes.url_helpers

  def build_line(sign)
    [
      url_for(sign.video),
      sign.usage_examples.map { |ue| url_for(ue) }.join("|"),
      sign.illustrations.map { |i| url_for(i) }.join("|"),
      sign.word,
      sign.maori,
      sign.secondary,
      sign.description,
      sign.notes,
      sign.topics.map(&:name).join("|")
    ].join(",")
  end

  let(:signs) do
    FactoryBot.create_list(:sign, 3, :processed, :with_illustrations, :with_usage_examples, :with_additional_info)
  end
  subject(:export) { described_class.new([signs[0].id, signs[1].id]) }

  describe ".to_csv" do
    subject(:csv) { export.to_csv }

    it "builds the expected CSV structure" do
      lines = csv.split("\n")
      expect(lines.first).to eq(
        "video_url,usage_example_urls,illustration_urls,word,maori,secondary,description,notes,topic_names"
      )
      expect(lines.size).to eq 3 # Headers plus 2 included signs
    end

    it "includes the expected data" do
      expect(csv).to include(build_line(signs[0]))
      expect(csv).to include(build_line(signs[1]))
      expect(csv).not_to include(build_line(signs[2]))
    end

    it "removes the separator if it is in an array" do
      signs[0].topics[0].update(name: "Separator|Test")
      expect(csv).to include("SeparatorTest")
      expect(csv).not_to include("Separator|Test")
    end

    it "joins topic names with a separator" do
      signs[0].update(topics: FactoryBot.create_list(:topic, 3))
      expect(csv).to include("#{signs[0].topics[0].name}|#{signs[0].topics[1].name}|#{signs[0].topics[2].name}")
    end

    it "joins usage example urls with a separator" do
      video_file = Rails.root.join("spec/fixtures/dummy.mp4").open
      video_file_io = { io: video_file, filename: File.basename(video_file) }
      signs[0].usage_examples.attach(video_file_io)
      expect(csv).to include("#{url_for(signs[0].usage_examples[0])}|#{url_for(signs[0].usage_examples[1])}")
    end

    it "joins illustration urls with a separator" do
      image_file = Rails.root.join("spec/fixtures/image.jpeg").open
      image_file_io = { io: image_file, filename: File.basename(image_file) }
      signs[0].illustrations.attach(image_file_io)
      expect(csv).to include("#{url_for(signs[0].illustrations[0])}|#{url_for(signs[0].illustrations[1])}")
    end
  end
end
