require "rails_helper"

RSpec.describe SearchService, type: :service do
  describe "search" do
    context "results" do
      before(:each) do
        %w[test testing tesla slapped apple].each { |title| FactoryBot.create(:sign, english: title) }
      end

      it "returns results given a word fragment" do
        expect(SearchService.call(search: Search.new(word: "tes")).data.count).to eq 3
        expect(SearchService.call(search: Search.new(word: "sla")).data.count).to eq 2
        expect(SearchService.call(search: Search.new(word: "app")).data.count).to eq 2
      end

      it "returns results given a complete word" do
        expect(SearchService.call(search: Search.new(word: "test")).data.count).to eq 2
        expect(SearchService.call(search: Search.new(word: "apple")).data.count).to eq 1
        expect(SearchService.call(search: Search.new(word: "tesla")).data.count).to eq 1
      end
    end
  end
end
