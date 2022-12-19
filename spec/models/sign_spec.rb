require "rails_helper"

RSpec.describe Sign, type: :model do
  subject(:sign) { FactoryBot.build(:sign) }

  it { is_expected.to be_valid }

  describe ".word" do
    context "blank" do
      before { sign.word = "" }
      it { is_expected.not_to be_valid }
    end
  end

  describe ".usage_examples" do
    it { expect(sign.usage_examples.build).to be_a ActiveStorage::Attachment }
  end

  describe ".illustrations" do
    it { expect(sign.usage_examples.build).to be_a ActiveStorage::Attachment }
  end

  describe ".video" do
    context "blank" do
      before { sign.video = nil }
      it { is_expected.not_to be_valid }
    end

    context "too large" do
      let(:invalid_blob_size) { 500.megabytes }
      before do
        allow(subject.video.blob).to receive(:byte_size) { invalid_blob_size }
        subject.valid?
      end

      it { is_expected.not_to be_valid }
      it { expect(subject.errors.full_messages).to include "Video file is too large (500 MB)" }
    end

    context "wrong type" do
      let(:invalid_content_type) { "application/pdf" }
      before do
        allow(subject.video.blob).to receive(:content_type) { invalid_content_type }
        subject.valid?
      end

      it { is_expected.not_to be_valid }

      it "adds the expected error" do
        subject.valid?;
        expect(subject.errors.full_messages).to include "Video file is not of an accepted type"
      end
    end
  end

  describe ".usage_examples" do
    let(:content_type) { "video/mp4" }
    let(:byte_size) { 10.megabytes }
    let(:blob) { double(ActiveStorage::Blob, byte_size: byte_size, content_type: content_type) }
    let(:attached) { double(ActiveStorage::Attached, attached?: true, blob: blob) }
    before { allow(subject).to receive(:usage_examples_attachments).and_return([attached]) }

    context "with a valid file" do
      it { is_expected.to be_valid }
    end

    context "blank" do
      before { sign.usage_examples = [] }
      it { is_expected.to be_valid }
    end

    context "too large" do
      let(:byte_size) { 500.megabytes }
      it { is_expected.not_to be_valid }
      it { subject.valid?; expect(subject.errors.full_messages).to include "Usage examples file is too large (500 MB)" }
    end

    context "wrong type" do
      let(:content_type) { "application/pdf" }
      it { is_expected.not_to be_valid }

      it "adds the expected error" do
        subject.valid?;
        expect(subject.errors.full_messages).to include "Usage examples file is not of an accepted type"
      end
    end

    context "more than 2 examples" do
      before { allow(subject).to receive(:usage_examples_attachments).and_return([attached, attached, attached]) }
      it { is_expected.not_to be_valid }
      it { subject.valid?; expect(subject.errors.full_messages).to include "Usage examples are limited to 2 files" }
    end
  end

  describe ".illustrations" do
    let(:content_type) { "image/jpeg" }
    let(:byte_size) { 10.megabytes }
    let(:blob) { double(ActiveStorage::Blob, byte_size: byte_size, content_type: content_type) }
    let(:attached) { double(ActiveStorage::Attached, attached?: true, blob: blob) }
    before { allow(subject).to receive(:illustrations_attachments).and_return([attached]) }

    context "with a valid file" do
      it { is_expected.to be_valid }
    end

    context "blank" do
      before { sign.illustrations = [] }
      it { is_expected.to be_valid }
    end

    context "too large" do
      let(:byte_size) { 500.megabytes }
      it { is_expected.not_to be_valid }
      it { subject.valid?; expect(subject.errors.full_messages).to include "Illustrations file is too large (500 MB)" }
    end

    context "wrong type" do
      let(:content_type) { "application/pdf" }
      it { is_expected.not_to be_valid }
      it "adds the expected error" do
        subject.valid?;
        expect(subject.errors.full_messages).to include "Illustrations file is not of an accepted type"
      end
    end

    context "more than 3 examples" do
      before do
        attachments = [attached, attached, attached, attached]
        allow(subject).to receive(:illustrations_attachments).and_return(attachments)
      end

      it { is_expected.not_to be_valid }
      it { subject.valid?; expect(subject.errors.full_messages).to include "Illustrations are limited to 3 files" }
    end
  end

  describe "#unpublish" do
    let(:model) { FactoryBot.create(:sign, :published) }
    before { allow(ArchiveSign).to receive_message_chain(:new, :process) }
    subject { model.unpublish! }

    context "invalid record" do
      before { allow(model).to receive(:save).and_return(false) }
      it "does not change the sign" do
        expect { subject }.to not_change(Sign, :count)
          .and not_change(FolderMembership, :count)
          .and not_change(model, :status).from("published")
      end
    end

    context "invalid transition" do
      let(:model) { FactoryBot.create(:sign, :submitted) }
      it "does not change the sign" do
        expect { subject }.to not_change(Sign, :count)
          .and not_change(FolderMembership, :count)
          .and not_change(model, :status).from("submitted")
      end
    end

    it "archives the sign during the transition" do
      archive_sign = double
      expect(ArchiveSign).to receive(:new).with(model).and_return(archive_sign)
      expect(archive_sign).to receive(:process)
      subject
    end

    it "removes folder memberships for the published sign" do
      folder_memberships = FactoryBot.create_list(:folder_membership, 5, sign: model)
      expect { subject }.to change(FolderMembership, :count).by(-folder_memberships.size)
    end

    it "transitions to 'personal'" do
      expect { subject }.to change(model, :status).to("personal")
    end
  end

  describe ".conditions_accepted" do
    context "this time, it's personal"

    it "adds an error if conditions are not accepted and sign is not 'personal'" do
      sign.status = :submitted
      sign.conditions_accepted = false
      expected_message = sign.errors.generate_message(:conditions_accepted, :blank)
      expect(sign).not_to be_valid
      expect(sign.errors.full_messages_for(:conditions_accepted).first).to include expected_message
    end
  end

  describe ".preview" do
    before { FactoryBot.create_list(:sign, 5) } # The limit is 4
    subject { Sign.preview }

    it "should have exactly 4 items, even though 5 exist in the table" do
      expect(subject.count).to eq 4
    end
  end

  describe ".recent" do
    it "returns the expected items in scope" do
      oldest = FactoryBot.create(:sign, :published, published_at: 1.hour.ago)
      newest = FactoryBot.create(:sign, :published, published_at: 1.minute.ago)
      middle = FactoryBot.create(:sign, :published, published_at: 10.minutes.ago)
      not_published = FactoryBot.create(:sign, :submitted, published_at: 10.minutes.ago)

      result = Sign.recent
      expect(result).to match_array([newest, middle, oldest])
      expect(result).not_to include not_published
    end
  end

  describe ".uncategorised" do
    it "returns expected records" do
      no_topic = FactoryBot.create(:sign)
      no_topic.sign_topics.destroy_all
      single_topic = FactoryBot.create(:sign)
      multiple_topics = FactoryBot.create(:sign, topics: Topic.all.sample(2))

      expect(described_class.uncategorised).to include no_topic
      expect(described_class.uncategorised).not_to include single_topic
      expect(described_class.uncategorised).not_to include multiple_topics
    end
  end
end
