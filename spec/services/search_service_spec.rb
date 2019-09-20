require "rails_helper"

RSpec.describe SearchService, type: :service do
  describe "search" do
    context "results" do
      before(:each) do
        %w[test testing tesla slapped apple].each { |title| FactoryBot.create(:sign, english: title) }
      end

      it "returns results given a word fragment" do
        expect(SearchService.call(word: "tes").results.data.count).to eq 3
        expect(SearchService.call(word: "sla").results.data.count).to eq 2
        expect(SearchService.call(word: "app").results.data.count).to eq 2
      end

      it "returns results given a complete word" do
        expect(SearchService.call(word: "test").results.data.count).to eq 2
        expect(SearchService.call(word: "apple").results.data.count).to eq 1
        expect(SearchService.call(word: "tesla").results.data.count).to eq 1
      end
    end
  end
end
