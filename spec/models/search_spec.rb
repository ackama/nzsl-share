require "rails_helper"

RSpec.describe Search, type: :model do
  describe "word" do
    context "whitespace" do
      it "removes leading and trailing whitespace" do
        expect(Search.new(word: " banana man ").word).to eq("banana man")
      end
    end

    context "truncate" do
      it "uses the first 50 chars for search" do
        str = "banana man is on the move protecting the city from the broccoli soup gang"
        expect(Search.new(word: str).word.chars.count).to eq(50)
        expect(Search.new(word: str).word).to eq(str.chars.first(50).join(""))
      end
    end
  end

  describe "published" do
    context "direction" do
      it "return 'ASC' given value 0" do
        expect(Search.new(published: 0).published).to eq("ASC")
      end

      it "return 'DESC' given value 1" do
        expect(Search.new(published: 1).published).to eq("DESC")
      end

      it "return falsey given other value" do
        expect(Search.new(published: 2).published).to be_nil
        expect(Search.new(published: "xxx").published).to be_nil
        expect(Search.new(published: -1000).published).to be_nil
      end
    end
  end

  describe "page" do
    context "pagination" do
      it "increments attributes given a word and page" do
        expect(Search.new(word: "a", page: 1).page).to eq(
          this_page: 1, next_page: 2, limit: 16, word: "a", next_pub: "0"
        )
        expect(Search.new(word: "a", page: 2).page).to eq(
          this_page: 2, next_page: 3, limit: 32, word: "a", next_pub: "0"
        )
        expect(Search.new(word: "a", page: 3).page).to eq(
          this_page: 3, next_page: 4, limit: 48, word: "a", next_pub: "0"
        )
        expect(Search.new(word: "a", page: 4).page).to eq(
          this_page: 4, next_page: 5, limit: 64, word: "a", next_pub: "0"
        )
      end
    end
  end
end
