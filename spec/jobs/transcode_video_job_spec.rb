require "rails_helper"

RSpec.describe TranscodeVideoJob, type: :job do
  let(:blob) { double(ActiveStorage::Blob) }
  let(:ffmpeg_args) { VideoEncodingPreset.default }
  let(:transcoder) { double }

  it "processes the blob to encode using the provided FFMpeg args" do
    expect(CachedVideoTranscoder).to receive(:new).with(blob, ffmpeg_args).and_return(transcoder)
    expect(transcoder).to receive(:processed)
    TranscodeVideoJob.perform_now(blob, ffmpeg_args)
  end
end
