require "rails_helper"

RSpec.describe Sign, type: :model do
  describe "validations" do
    it { expect(subject).to validate_length_of(:english) }
  end

  describe "search" do
    it "returns an empty array given an empty value" do
      expect(Sign.search("")).to eq []
      expect(Sign.search(nil)).to eq []
    end

    context "results" do
      before(:each) do
        %w[test testing tesla slapped apple].each { |title| FactoryBot.create(:sign, english: title) }
      end

      it "returns results given a word fragment" do
        expect(Sign.search("tes").count).to eq 3
        expect(Sign.search("sla").count).to eq 2
        expect(Sign.search("app").count).to eq 2
      end

      it "returns results given a complete word" do
        expect(Sign.search("test").count).to eq 2
        expect(Sign.search("apple").count).to eq 1
        expect(Sign.search("tesla").count).to eq 1
      end
    end
  end
end
