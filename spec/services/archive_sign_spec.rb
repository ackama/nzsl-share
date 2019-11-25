require "rails_helper"

RSpec.describe ArchiveSign, type: :service do
  let!(:sign) { FactoryBot.create(:sign) }
  let(:user) { FactoryBot.create(:user) }

  subject(:svc) { ArchiveSign.new(sign, user) }

  describe "#process" do
    subject { svc.process }
    it "creates an archived copy of the sign" do
      clone = nil
      expect { clone = subject }.to change(Sign, :count)
      expect(clone.word).to eq sign.word
      expect(clone).to be_archived
    end

    it "updates the contributor on the new sign to the provided user" do
      clone = subject
      expect(clone.contributor).to eq user
    end

    it "changes the status of the sign copy to 'archived'" do
      expect(subject).to be_archived
    end

    it "creates a new attachment for the sign video" do
      clone = nil
      expect { clone = subject }.to change(ActiveStorage::Attachment, :count).by(1)
      expect(clone.video.blob).to eq sign.video.blob
      expect(blob_exists?(clone.video.blob)).to eq true
    end

    context "shared sign" do
      let(:sign) { FactoryBot.create(:sign, share_token: "abc123") }

      it "clears the share token on the duplicated sign" do
        clone = subject
        expect(clone.share_token).not_to eq sign.share_token
        expect(clone.share_token).to eq nil
      end
    end

    context "with usage examples" do
      let!(:sign) { FactoryBot.create(:sign, :with_usage_examples) }

      it "creates new attachments for the usage examples" do
        clone = nil
        expected_count = sign.usage_examples.size + 1 # +1 = sign video
        expect { clone = subject }.to change(ActiveStorage::Attachment, :count).by(expected_count)
        expect(clone.usage_examples.size).to eq sign.usage_examples.size
      end
    end

    context "with illustrations" do
      let!(:sign) { FactoryBot.create(:sign, :with_illustrations) }

      it "creates new attachments for the illustrations" do
        clone = nil
        expected_count = sign.illustrations.size + 1 # +1 = sign video
        expect { clone = subject }.to change(ActiveStorage::Attachment, :count).by(expected_count)
        expect(clone.illustrations.size).to eq sign.illustrations.size
      end
    end

    context "when the original sign is destroyed" do
      let!(:clone) { svc.process }

      it "still keeps the attachment blobs linked to the cloned sign" do
        sign.destroy
        expect(blob_exists?(clone.video.blob)).to be true
      end
    end

    private

    def blob_exists?(blob)
      blob.service.exist?(blob.key)
    end
  end
end
