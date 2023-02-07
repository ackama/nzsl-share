require "rails_helper"

RSpec.describe SignUpdater, type: :service do
  let(:sign) { FactoryBot.create(:sign) }

  describe ".update" do
    it "updates the record" do
      expect { described_class.new(sign, { notes: "Test notes" }).update }.to change(sign, :notes)
    end

    it "post-processes the record when the video is provided" do
      processor = instance_spy(SignPostProcessor)
      allow(SignPostProcessor).to receive(:new).and_return(processor)
      described_class.new(sign, { video: fixture_file_upload("spec/fixtures/small.mp4") }).update
      expect(processor).to have_received(:process)
    end

    it "does not post-process the record when the video is not provided" do
      allow(SignPostProcessor).to receive(:new)
      described_class.new(sign, { notes: "My cool record" }).update
      expect(SignPostProcessor).not_to have_received(:new)
    end

    it "does not post-process the record when the record is invalid" do
      allow(SignPostProcessor).to receive(:new)
      described_class.new(sign, { word: "" }).update
      expect(sign.errors[:word]).to eq ["can't be blank"]
      expect(SignPostProcessor).not_to have_received(:new)
    end
  end
end
