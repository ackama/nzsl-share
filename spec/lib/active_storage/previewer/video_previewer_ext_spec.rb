require "rails_helper"

RSpec.describe ActiveStorage::Previewer::VideoPreviewer do
  it "generates a preview of a video at the expectect proportional position" do
    blob = ActiveStorage::Blob.create_and_upload!(
      key: SecureRandom.uuid,
      filename: "dummy.mp4",
      io: fixture_file_upload("spec/fixtures/dummy.mp4")
    )

    previewer = described_class.new(blob)
    allow(blob).to receive(:metadata).and_return(duration: 6) # Fake the video file duration
    allow(previewer).to receive(:draw).and_call_original
    previewer.preview {} # Preview requires a block, we don't need to do anything with the result though

    expect(previewer).to have_received(:draw) do |*args|
      # fixture file has a fake duration of 6s, we proportionally seek 25% though
      expected_frame_time = "1.5"
      expect(args).to include "-ss"
      expect(args).to include expected_frame_time
    end
  end
end
