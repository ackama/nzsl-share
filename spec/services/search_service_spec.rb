require "rails_helper"
require "./spec/support/refined_data/search"

RSpec.describe SearchService, type: :service do
  describe "search" do
    context "english and secondary" do
      before(:each) do
        Refined::Search::Data.signs.each do |sign_attrs|
          FactoryBot.create(:sign, sign_attrs)
        end
      end

      it "returns result(s) given a word fragment" do
        expect(SearchService.call(search: Search.new(word: "a")).data.count).to eq 14
        expect(SearchService.call(search: Search.new(word: "ap")).data.count).to eq 2
        expect(SearchService.call(search: Search.new(word: "app")).data.count).to eq 1
        expect(SearchService.call(search: Search.new(word: "appl")).data.count).to eq 1

        expect(SearchService.call(search: Search.new(word: "p")).data.count).to eq 9
        expect(SearchService.call(search: Search.new(word: "pp")).data.count).to eq 1
        expect(SearchService.call(search: Search.new(word: "ppl")).data.count).to eq 1
        expect(SearchService.call(search: Search.new(word: "pple")).data.count).to eq 1

        expect(SearchService.call(search: Search.new(word: "p")).data.count).to eq 9
        expect(SearchService.call(search: Search.new(word: "pl")).data.count).to eq 1
        expect(SearchService.call(search: Search.new(word: "ple")).data.count).to eq 1

        expect(SearchService.call(search: Search.new(word: "l")).data.count).to eq 7
        expect(SearchService.call(search: Search.new(word: "le")).data.count).to eq 2

        expect(SearchService.call(search: Search.new(word: "e")).data.count).to eq 9
      end

      it "returns result(s) given a complete word" do
        expect(SearchService.call(search: Search.new(word: "pie")).data.count).to eq 3
        expect(SearchService.call(search: Search.new(word: "america")).data.count).to eq 3
        expect(SearchService.call(search: Search.new(word: "risotto")).data.count).to eq 2
        expect(SearchService.call(search: Search.new(word: "england")).data.count).to eq 2
        expect(SearchService.call(search: Search.new(word: "soup")).data.count).to eq 2
        expect(SearchService.call(search: Search.new(word: "cream")).data.count).to eq 2
        expect(SearchService.call(search: Search.new(word: "apple")).data.count).to eq 1
      end

      it "returns an exact match first given a complete word" do
        expect(SearchService.call(search: Search.new(word: "apple"))
           .data.first.fetch_values("english", "secondary").to_s.include?("apple")).to be true
        expect(SearchService.call(search: Search.new(word: "pie"))
          .data.first.fetch_values("english", "secondary").to_s.include?("pie")).to be true
        expect(SearchService.call(search: Search.new(word: "banana"))
          .data.first.fetch_values("english", "secondary").to_s.include?("banana")).to be true
        expect(SearchService.call(search: Search.new(word: "england"))
          .data.first.fetch_values("english", "secondary").to_s.include?("england")).to be true
        expect(SearchService.call(search: Search.new(word: "cream"))
          .data.first.fetch_values("english", "secondary").to_s.include?("cream")).to be true
        expect(SearchService.call(search: Search.new(word: "risotto"))
          .data.first.fetch_values("english", "secondary").to_s.include?("risotto")).to be true
        expect(SearchService.call(search: Search.new(word: "blueberry"))
          .data.first.fetch_values("english", "secondary").to_s.include?("blueberry")).to be true
      end
    end

    context "published date" do
      before(:each) do
        Refined::Search::Data.signs.each do |hsh|
          Sign.create(hsh)
        end
      end

      it "orders ascending given a '0'" do
        rs1 = SearchService.call(search: Search.new(word: "a", order: { published: "ASC" }))
                           .data.map { |hsh| hsh["published_at"] }

        rs2 = SearchService.call(search: Search.new(word: "a", order: { published: "DESC" }))
                           .data.map { |hsh| hsh["published_at"] }.sort

        expect(rs1 == rs2).to be true
      end

      it "orders descending given a '1'" do
        rs1 = SearchService.call(search: Search.new(word: "a", order: { published: "DESC" }))
                           .data.map { |hsh| hsh["published_at"] }

        rs2 = SearchService.call(search: Search.new(word: "a", order: { published: "ASC" }))
                           .data.map { |hsh| hsh["published_at"] }.sort.reverse

        expect(rs1 == rs2).to be true
      end
    end
  end
end
