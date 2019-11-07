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
      it { expect(subject.errors.full_messages).to include "Video isn't a valid video file" }
    end
  end

  describe ".conditions_accepted" do
    context "this time, it's personal"

    it "adds an error if conditions are not accepted and sign is not 'personal'" do
      sign.status = :submitted
      sign.conditions_accepted = false
      expected_message = sign.errors.generate_message(:conditions_accepted, :blank)
      expect(sign).not_to be_valid
      expect(sign.errors.full_messages_for(:conditions_accepted)).to include expected_message
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
