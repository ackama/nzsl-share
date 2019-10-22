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
  let(:transcode_options) { ["-f", "ogg"] }

  subject(:service) { VideoTranscoder.new(transcode_options) }

  describe "#transcode" do
    subject { service.transcode(blob) }

    it "transcodes a video with the expected command" do
      expect(service).to receive(:exec).with(
        "ffmpeg", "-y", "-i", start_with("/tmp/ActiveStorage-"),
        "-f", "ogg", start_with("/tmp/NZSL-VideoEncode")).and_call_original

      subject
    end

    it "derives the expected content type from the transcoded file" do
      expect(subject[:content_type]).to eq "video/ogg"
    end

    it "derives the expected filename from the transcoded file" do
      expect(subject[:filename]).to eq "dummy.ogg"
    end

    context "when a block is passed" do
      it "yields the result" do
        expect do |b|
          service.transcode(blob, &b)
        end.to yield_with_args(
          hash_including(:io, :filename, :content_type)
        )
      end
    end

    context "when the transcode command fails" do
      let(:transcode_options) { ["-f", "madeup"] }
      it "raises a transcode error" do
        expect { subject }.to raise_error VideoTranscoder::TranscodeError
      end
    end
  end
end
