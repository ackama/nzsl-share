require "rails_helper"

RSpec.describe DictionarySearchService, type: :service do
  describe "#initialize" do
    it "delegates to FreelexSearchService when provided with a FreelexSign scope" do
      relation = FreelexSign.all
      search = Search.new(term: "test")
      expect(described_class.new(relation: relation, search: search).__getobj__).to be_a FreelexSearchService
    end

    it "delegates to SignbankSearchService when provided with a DictionarySign scope" do
      relation = DictionarySign.all
      search = Search.new(term: "test")
      expect(described_class.new(relation: relation, search: search).__getobj__).to be_a SignbankSearchService
    end
  end
end
