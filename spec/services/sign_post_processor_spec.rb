require "rails_helper"

RSpec.describe SignPostProcessor, type: :service do
  let(:sign) { FactoryBot.create(:sign) }
  subject(:service) { SignPostProcessor.new(sign) }

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
      expect(thumbnail_batch.description).to eq "Post processing: Generate thumbnails for Sign ##{sign.id}"
      expect(video_batch.description).to eq "Post processing: Transcode videos for Sign ##{sign.id}"
    end

    it "establishes the expected callbacks" do
      batch_double = double.as_null_object
      allow(service).to receive(:new_batch).and_return(batch_double)

      expect(batch_double).to receive(:on).with(
        :success,
        SignPostProcessor::VideoCallback,
        sign_id: sign.id)

      expect(batch_double).to receive(:on).with(
        :success,
        SignPostProcessor::ThumbnailCallback,
        sign_id: sign.id)

      subject
    end
  end

  describe SignPostProcessor::ThumbnailCallback do
    subject { described_class.new.on_success(nil, "sign_id" => sign.id); sign.reload }
    it { expect { subject }.not_to change(sign, :processed_videos?) }
    it { expect { subject }.to change(sign, :processed_thumbnails?).to eq true }
  end

  describe SignPostProcessor::VideoCallback do
    subject { described_class.new.on_success(nil, "sign_id" => sign.id); sign.reload }
    it { expect { subject }.to change(sign, :processed_videos?).to eq true }
    it { expect { subject }.not_to change(sign, :processed_thumbnails?) }
  end
end
