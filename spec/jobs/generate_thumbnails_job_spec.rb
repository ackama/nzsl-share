require "rails_helper"

RSpec.describe GenerateThumbnailJob, type: :job do
  let(:blob) { double(ActiveStorage::Blob) }
  let(:preview_settings) { ThumbnailPreset.default }
  let(:preview) { double }

  it "generates a preview of the blob with the provided settings" do
    expect(blob).to receive(:preview).with(preview_settings).and_return(preview)
    expect(preview).to receive(:processed)
    GenerateThumbnailJob.perform_now(blob, preview_settings)
  end
end
