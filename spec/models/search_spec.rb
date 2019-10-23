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
      it { expect(Search.new(order: { published: "ASC" }).order).to eq("published" => "ASC") }
      it { expect(Search.new(order: { published: "DESC" }).order).to eq("published" => "DESC") }

      it "returns an empty hash given invalid key/value" do
        expect(Search.new(order: { published: 42 }).order).to eq({})
        expect(Search.new(order: { published: "qwerty" }).order).to eq({})
        expect(Search.new(order: { published: -42 }).order).to eq({})
        expect(Search.new(order: { pesto: "olive" }).order).to eq({})
        expect(Search.new(order: { spritz: "yum!" }).order).to eq({})
      end
    end
  end

  describe "page" do
    context "pagination" do
      it "increments attributes given a word and page" do
        expect(Search.new(word: "a", page: 1).page)
          .to eq(current_page: 1, next_page: 2, limit: 16, previous_limit: 16, word: "a")
        expect(Search.new(word: "a", page: 2).page)
          .to eq(current_page: 2, next_page: 3, limit: 32, previous_limit: 16, word: "a")
        expect(Search.new(word: "a", page: 3)
          .page).to eq(current_page: 3, next_page: 4, limit: 48, previous_limit: 32, word: "a")
        expect(Search.new(word: "a", page: 4)
          .page).to eq(current_page: 4, next_page: 5, limit: 64, previous_limit: 48, word: "a")
      end
    end
  end
end
