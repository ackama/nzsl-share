require "rails_helper"

RSpec.describe DictionarySignPresenter, type: :presenter do
  let(:sign) { DictionarySign.find("4432") } # 'chocolate'
  subject(:presenter) { described_class.new(sign, view) }

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

  describe "#url" do
    subject { presenter.url }
    it { is_expected.to eq "https://nzsl.nz/signs/4432" }
  end

  describe "#sign_video_sourceset" do
    subject { presenter.sign_video_sourceset }

    it "returns an mp4 source to the video key" do
      source = "<source src=\"#{sign.video}\"></source>"
      expect(subject).to include source
    end
  end
end
