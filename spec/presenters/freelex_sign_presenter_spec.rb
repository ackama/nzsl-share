require "rails_helper"

RSpec.describe FreelexSignPresenter, type: :presenter do
  let(:sign) { FactoryBot.build_stubbed(:freelex_sign) }
  subject(:presenter) { FreelexSignPresenter.new(sign, view) }

  it "exposes a selection of core sign attributes" do
    %w[word secondary maori].each do |sign_attr|
      expect(sign).to receive(sign_attr)
      subject.public_send(sign_attr)
    end
  end

  describe "#truncated_secondary" do
    it "truncates something that is too long" do
      sign.secondary = <<~LOREM
        Lorem ipsum dolor sit amet, consectetur adipiscing elit,
        sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
      LOREM

      expect(presenter.truncated_secondary.length).not_to eq sign.secondary.length
      expect(presenter.truncated_secondary).to end_with "..."
    end

    it "does not truncate something that is not too long" do
      sign.secondary = "normal secondary length"

      expect(presenter.truncated_secondary.length).to eq sign.secondary.length
      expect(presenter.truncated_secondary).not_to end_with "..."
    end
  end

  describe "#sign_video_attributes" do
    subject { presenter.sign_video_attributes }
    it "includes default video attributes" do
      expect(subject).to include(muted: true)
    end

    it "assigns a 'has-video' class" do
      expect(subject).to include(class: "video has-video")
    end
  end

  describe "#url" do
    let(:sign) { FactoryBot.build(:freelex_sign, headword_id: 1) }
    subject { presenter.url }
    it { is_expected.to eq "https://nzsl.nz/signs/1" }
  end

  describe "#sign_video_sourceset" do
    let(:sign) { FactoryBot.build(:freelex_sign, video_key: ["video/sign.webm", "video/sign.mp4"]) }
    subject { presenter.sign_video_sourceset }

    it "returns a webm source to the video key" do
      source = "<source src=\"#{FREELEX_CONFIG[:asset_host]}video/sign.webm\"></source>"
      expect(subject).to include source
    end

    it "returns an mp4 source to the video key" do
      source = "<source src=\"#{FREELEX_CONFIG[:asset_host]}video/sign.mp4\"></source>"
      expect(subject).to include source
    end
  end
end
