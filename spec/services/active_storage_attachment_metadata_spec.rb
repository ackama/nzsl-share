require "rails_helper"

RSpec.describe ActiveStorageAttachmentMetadata, type: :service do
  let(:attachment) { FactoryBot.create(:sign).video }
  let(:actual_metadata) { attachment.blob.metadata }
  subject(:svc) { described_class.new(attachment) }

  describe "#set" do
    subject { svc.set("key", "value") }

    context "empty metadata" do
      before { attachment.blob.metadata = {} }
      it { expect { subject }.to change { actual_metadata }.to eq("key" => "value") }
    end

    context "existing metadata" do
      before { attachment.blob.metadata = { analyzed: true } }
      it { expect { subject }.to change { actual_metadata }.to eq("analyzed" => true, "key" => "value") }
    end
  end

  describe "#get" do
    subject { svc.get("key") }

    context "key exists" do
      before { svc.set("key", "value") }
      it { is_expected.to eq "value" }
    end

    context "key does not exist" do
      it { is_expected.to be_nil }
    end
  end

  describe "#all" do
    subject { svc.all }
    it { is_expected.to eq actual_metadata }
  end

  describe "#save!" do
    subject { svc.send(:save!) }
    it "persists the modified metadata on the blob" do
      expect(attachment.blob).to receive(:update!).with(metadata: actual_metadata)
      subject
    end
  end
end
