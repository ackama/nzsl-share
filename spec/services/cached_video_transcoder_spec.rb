require "rails_helper"

RSpec.describe CachedVideoTranscoder, type: :service do
  let(:fake_processor) { double }
  let(:fake_processor_class) { double(new: fake_processor) }
  let(:io) { File.open(Rails.root.join("spec", "fixtures", "dummy.mp4")) }
  let(:transcode_options) { {} }
  let(:new_blob) do
    ActiveStorage::Blob.create_after_upload!(
      io: io,
      filename: "dummy.mp4",
      content_type: "video/mp4"
    )
  end

  before { transcoder.send(:ensure_active_storage_host) }

  let(:processed_blob) do
    new_key = CachedVideoTranscoder.new(new_blob, {}).send(:key)

    new_blob.service.upload(
      new_key,
      io,
      filename: new_blob.filename,
      content_type: new_blob.content_type
    )

    new_blob.clone.tap { |b| b.update!(key: new_key) }
  end

  # Default
  let(:blob) { new_blob }

  subject(:transcoder) { CachedVideoTranscoder.new(blob, transcode_options, processor: fake_processor_class) }

  describe "#exist?" do
    subject { transcoder.exist? }
    it "delegates to service.exist? with the derived key" do
      expected_key = transcoder.send(:key)
      expect(transcoder.service).to receive(:exist?).with(expected_key)
      subject
    end
  end

  describe "#process_later" do
    subject { transcoder.process_later }
    it "enqueues the expected job" do
      ActiveJob::Base.queue_adapter = :test
      expect { subject }.to have_enqueued_job(TranscodeVideoJob).with(blob, transcode_options)
    end
  end

  describe "#processed" do
    subject { transcoder.processed }

    context "already processed" do
      let(:blob) { processed_blob }

      it "doesn't reprocess" do
        expect(transcoder).not_to receive(:process)
        subject
      end

      it "returns the URL for the new blob" do
        expect(transcoder.send(:encoded_blob)).to receive(:service_url)
        subject
      end
    end

    context "not yet processed" do
      it "triggers the process" do
        expect(transcoder).to receive(:process)
        subject
      end
    end
  end

  describe "#process" do
    subject { transcoder.send(:process) }
    let(:process_result) { { io: io, filename: "test.vid", content_type: "video/video" } }
    before { allow(fake_processor).to receive(:transcode).and_yield(process_result) }

    it "transcodes the blob" do
      expect(fake_processor).to receive(:transcode).with(blob)
      subject
    end

    it "uploads the blob" do
      service = transcoder.service
      expect(service).to receive(:upload).with(an_instance_of(String), io, hash_including(:content_type, :filename))
      subject
    end

    it "persists the blob and returns the URL to the persisted blob" do
      expect(transcoder).to receive(:persist_blob).with(process_result).and_return(processed_blob)
      expect(processed_blob).to receive(:service_url)
      subject
    end

    context "blob already processed" do
      let(:blob) { processed_blob }

      it "removes the existing blob before proceeding" do
        expect(processed_blob).to receive(:purge).and_call_original
        subject
      end
    end
  end

  describe "#processed?" do
    subject { transcoder.send(:processed?) }

    context "encoded blob is present and uploaded" do
      let(:blob) { processed_blob }
      it { is_expected.to eq true }
    end

    context "encoded blob is present, but not uploaded" do
      let(:blob) { processed_blob }
      before { transcoder.service.delete(processed_blob.key) }

      it { is_expected.not_to eq true }
    end

    context "no encoded blob" do
      let(:blob) { new_blob }
      it { is_expected.not_to eq true }
    end
  end

  describe "#encoded_blob" do
    subject { transcoder.send(:encoded_blob) }

    it "finds and memoizes using the service-generated key for the blob" do
      expect(ActiveStorage::Blob).to receive(:find_by).once.with(key: transcoder.send(:key))
      subject
      subject # Called again to assert memoization
    end
  end

  describe "#persist_blob" do
    let(:file) { { io: io, filename: "test.vid", content_type: "video/video" } }
    subject { transcoder.send(:persist_blob, file) }

    it "generates the expected record given a valid file hash" do
      expect(subject.byte_size).to eq File.size(io)
      expect(subject.content_type).to eq "video/mp4" # Derived from actual IO
      expect(subject.filename).to eq "test.vid"

      # Very important check to make sure that ActiveStorage does not
      # override the key with what it thinks it _should_ be.
      expect(subject.key).to eq transcoder.send(:key)
    end
  end

  describe "#key" do
    subject { transcoder.send(:key) }

    context "normal blob" do
      let(:blob) { new_blob }

      it "encodes a variant key based on the new blob" do
        parts = subject.split("/")
        expect(parts.first).to eq "variants"
        expect(parts.second).to eq blob.key
        expect(parts.third).to be_a String # Options digest
      end
    end

    context "already a variant" do
      let(:blob) { processed_blob }
      it { is_expected.to eq blob.key }
    end

    context "with different encoding options" do
      let(:transcode_options) { { different_options: true } }

      # We use a variant blob here so we can compare the third key part
      let(:blob) { processed_blob }

      it "generates a different key" do
        parts = subject.split("/")
        blob_parts = blob.key.split("/")
        expect(parts.first).to eq blob_parts.first
        expect(parts.second).to eq blob_parts.second
        expect(parts.third).not_to eq blob_parts.third
      end
    end
  end
end
