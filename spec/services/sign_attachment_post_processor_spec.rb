require "rails_helper"

RSpec.describe SignAttachmentPostProcessor, type: :service do
  let(:sign) { FactoryBot.create(:sign, :with_usage_examples) }
  let(:blob) { sign.usage_examples.first.blob }
  subject(:service) { SignAttachmentPostProcessor.new(blob) }

  describe "#process" do
    subject { service.process }

    it "batches thumbnail generation" do
      ActiveJob::Base.queue_adapter = :test
      number_of_presets = service.send(:default_presets)[:video].size
      expect { subject }.to enqueue_job(GenerateThumbnailJob).exactly(number_of_presets).times
    end

    it "batches video generation" do
      ActiveJob::Base.queue_adapter = :test
      number_of_presets = service.send(:default_presets)[:thumbnail].size
      expect { subject }.to enqueue_job(TranscodeVideoJob).exactly(number_of_presets).times
    end

    it "identifies the batches" do
      thumbnail_batch, video_batch = subject
      expect(thumbnail_batch.description).to eq "Post processing: Generate thumbnails for Blob ##{blob.id}"
      expect(video_batch.description).to eq "Post processing: Transcode videos for Blob ##{blob.id}"
    end

    context "blob is not a video" do
      before { allow(blob).to receive(:video?).and_return(false) }

      it "does not enqueue transcode jobs" do
        ActiveJob::Base.queue_adapter = :test
        expect { subject }.not_to enqueue_job(TranscodeVideoJob)
      end
    end
  end
end
