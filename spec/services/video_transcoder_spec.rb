require "rails_helper"

RSpec.describe VideoTranscoder, type: :service do
  let(:blob) do
    ActiveStorage::Blob.create_after_upload!(
      io: File.open(Rails.root.join("spec", "fixtures", "dummy.mp4")),
      filename: "dummy.mp4",
      content_type: "video/mp4"
    )
  end

  # A minimal transcode
  let(:transcode_options) { ["-f", "avi"] }

  subject(:service) { VideoTranscoder.new(transcode_options) }

  describe "#transcode" do
    subject { service.transcode(blob) }

    it "transcodes a video with the expected command"
    it "creates a new blob with the transcode result"
    it "nests the new blob key under the original blob"
    it "derives the expected content type from the transcoded file"
    it "derives the expected filename from the transcoded file"

    context "with a variant" do
      it "doesn't deeply nest the key"
    end

    context "when the transcode command fails" do
      it "raises a transcode error"
    end
  end
end
