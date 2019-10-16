require "rails_helper"

RSpec.describe SignBuilder, type: :service do
  describe ".build" do
    subject { SignBuilder.new.build(attrs) }

    context "word is already present" do
      let(:attrs) { FactoryBot.attributes_for(:sign) }
      it "has attached the video" do
        expect(subject.video).to be_present
      end

      it "has left the word set to its initial value" do
        expect(subject.english).to eq attrs[:english]
      end
    end

    context "attachment is present" do
      let(:attrs) { FactoryBot.attributes_for(:sign, english: "") }
      it "has assigned the word to the attachment filename" do
        expect(subject.english).to eq "dummy"
      end
    end

    context "attachment is not present" do
      let(:attrs) { FactoryBot.attributes_for(:sign, english: "", video: nil) }
      it "has assigned the word to the default placeholder value" do
        expect(subject.english).to eq "My New Sign"
      end
    end
  end
end
