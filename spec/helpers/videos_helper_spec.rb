require "rails_helper"

RSpec.describe VideosHelper, type: :helper do
  let(:signed_id) { "abc123" }
  let(:video) { double(signed_id: signed_id) }

  describe "#video_source_tag" do
    subject { helper.video_source_tag(video, "720p") }
    it { is_expected.to eq "<source src=\"/videos/#{signed_id}/720p\"></source>" }
  end

  describe "#video_sourceset" do
    subject { helper.video_sourceset(video) }
    it "renders with default presets" do
      matcher = %r{<source src="/videos/#{signed_id}/(1080|720|360)p">}
      expect(subject.scan(matcher).size).to eq 3
    end

    it "renders with different presets" do
      result = helper.video_sourceset(video, ["240p"])
      expect(result).to include "<source src=\"/videos/#{signed_id}/240p\">"
    end
  end

  describe "#video_attributes" do
    subject { helper.video_attributes }

    it { expect(subject[:preload]).to eq false }
    it { expect(subject[:controls]).to eq true }
    it { expect(subject[:muted]).to eq true }

    context "with additional attributes" do
      subject { helper.video_attributes(extra_option: true) }
      it { expect(subject).to have_key :extra_option }
    end

    context "with classes" do
      subject { helper.video_attributes(class: "override class") }
      it { expect(subject[:class]).to eq "video override class" }
    end
  end
end
