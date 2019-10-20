require "rails_helper"

RSpec.describe CachedVideoTranscoder, type: :service do
  let(:fake_processor) { double }
  let(:transcode_options) { {} }
  let(:blob) do
    ActiveStorage::Blob.create_after_upload!(
      io: File.open(Rails.root.join("spec", "fixtures", "dummy.mp4")),
      filename: "dummy.mp4",
      content_type: "video/mp4"
    )
  end

  subject(:service) { CachedVideoTranscoder.new(blob, transcode_options, processor: fake_processor) }

  describe "#exist?" do
    it "delegates to service.exist? with the derived key"
  end

  describe "#process_later" do
    it "enqueues the expected job"
  end

  describe "#processed" do
    context "already processed" do
      it "returns the URL for the new blob"
    end

    context "not yet processed" do
      it "triggers the process"
    end
  end

  describe "#process" do
    it "transcodes the blob"
    it "uploads the blob"
    it "persists the blob"
    it "returns the URL to the new blob"

    context "blob already processed" do
      it "removes the existing blob before proceeding"
    end
  end

  describe "#processed?" do
    context "encoded blob is present and uploaded"
    context "encoded blob is present, but not uploaded"
    context "no encoded blob"
  end

  describe "#encoded_blob" do
    it "finds using the service-generated key"
    it "memoizes"
  end

  describe "#persist_blob" do
    it "generates the expected record given a valid file hash"
  end

  describe "#key" do
    context "normal blob"
    context "already a variant"
    context "variant of a variant (just in case)"
  end
end
