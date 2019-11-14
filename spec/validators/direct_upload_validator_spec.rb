require "rails_helper"

RSpec.describe DirectUploadValidator, type: :validator do
  describe ".validate!" do
    subject { described_class.new.validate!(blob_args) }
    let(:blob_args) { { byte_size: 10.megabytes, content_type: "video/mp4" } }

    context "arguments are acceptable" do
      it { expect(subject).to eq true }
    end

    context "arguments are unacceptable (file too large)" do
      let(:blob_args) { super().merge(byte_size: 500.megabytes) }

      it "raises an ActiveRecord::RecordInvalid with the expected error" do
        expect { subject }.to raise_error ActiveRecord::RecordInvalid do |invalid|
          expect(invalid.record.errors[:attachment]).to eq ["file is too large (500 MB)"]
        end
      end
    end

    context "arguments are unacceptable (file incorrect type)" do
      let(:blob_args) { super().merge(content_type: "application/pdf") }

      it "raises an ActiveRecord::RecordInvalid with the expected error" do
        expect { subject }.to raise_error ActiveRecord::RecordInvalid do |invalid|
          expect(invalid.record.errors[:attachment]).to eq ["file is not of an accepted type"]
        end
      end
    end
  end
end
