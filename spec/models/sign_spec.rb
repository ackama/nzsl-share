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
    before { allow(ArchiveSign).to receive(:call) }
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
      expect(ArchiveSign).to receive(:call)
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
end
