require "rails_helper"

RSpec.describe Search, type: :model do
  describe "#term" do
    context "whitespace" do
      it "removes leading and trailing whitespace" do
        expect(Search.new(term: " banana man ").term).to eq("banana man")
      end
    end

    context "truncate" do
      it "uses the first 50 chars for search" do
        str = "banana man is on the move protecting the city from the broccoli soup gang"
        expect(Search.new(term: str).term.chars.count).to eq(50)
        expect(Search.new(term: str).term).to eq(str[0...50].chars.join)
      end
    end
  end

  describe "#order_clause" do
    subject { Search.new(sort:).order_clause }

    context "with a known sort" do
      let(:sort) { "recent" }
      it { is_expected.to eq("published_at DESC") }
    end

    context "with an unknown sort" do
      let(:sort) { "qwerty" }
      it { is_expected.to eq("word ASC") }
    end
  end

  describe "page" do
    context "pagination" do
      it "increments attributes given a term and page" do
        expect(Search.new(term: "a", page: 1).page).to eq(current_page: 1, next_page: 2, limit: 16, term: "a")
        expect(Search.new(term: "a", page: 2).page).to eq(current_page: 2, next_page: 3, limit: 32, term: "a")
        expect(Search.new(term: "a", page: 3).page).to eq(current_page: 3, next_page: 4, limit: 48, term: "a")
        expect(Search.new(term: "a", page: 4).page).to eq(current_page: 4, next_page: 5, limit: 64, term: "a")
      end
    end
  end
end
