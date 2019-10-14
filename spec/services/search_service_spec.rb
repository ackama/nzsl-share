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
        expect(SearchService.call(search: Search.new(word: "a")).data.count).to eq 7
        expect(SearchService.call(search: Search.new(word: "ap")).data.count).to eq 2
        expect(SearchService.call(search: Search.new(word: "app")).data.count).to eq 1
        expect(SearchService.call(search: Search.new(word: "appl")).data.count).to eq 1

        expect(SearchService.call(search: Search.new(word: "p")).data.count).to eq 6
        expect(SearchService.call(search: Search.new(word: "pp")).data.count).to eq 1
        expect(SearchService.call(search: Search.new(word: "ppl")).data.count).to eq 1
        expect(SearchService.call(search: Search.new(word: "pple")).data.count).to eq 1

        expect(SearchService.call(search: Search.new(word: "p")).data.count).to eq 6
        expect(SearchService.call(search: Search.new(word: "pl")).data.count).to eq 1
        expect(SearchService.call(search: Search.new(word: "ple")).data.count).to eq 1

        expect(SearchService.call(search: Search.new(word: "l")).data.count).to eq 7
        expect(SearchService.call(search: Search.new(word: "le")).data.count).to eq 2

        expect(SearchService.call(search: Search.new(word: "e")).data.count).to eq 7
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
           .data.pluck(:english, :secondary).flatten.to_s.include?("apple")).to be true
        expect(SearchService.call(search: Search.new(word: "pie"))
          .data.pluck(:english, :secondary).flatten.to_s.include?("pie")).to be true
        expect(SearchService.call(search: Search.new(word: "banana"))
          .data.pluck(:english, :secondary).flatten.to_s.include?("banana")).to be true
        expect(SearchService.call(search: Search.new(word: "england"))
          .data.pluck(:english, :secondary).flatten.to_s.include?("england")).to be true
        expect(SearchService.call(search: Search.new(word: "cream"))
          .data.pluck(:english, :secondary).flatten.to_s.include?("cream")).to be true
        expect(SearchService.call(search: Search.new(word: "risotto"))
          .data.pluck(:english, :secondary).flatten.to_s.include?("risotto")).to be true
        expect(SearchService.call(search: Search.new(word: "blueberry"))
          .data.pluck(:english, :secondary).flatten.to_s.include?("blueberry")).to be true
      end
    end

    context "macrons" do
      before(:each) do
        Refined::Search::Data.signs_with_macrons.each do |sign_attrs|
          FactoryBot.create(:sign, sign_attrs)
        end
      end

      it "return result(s) regardless of macron" do
        expect(SearchService.call(search: Search.new(word: "āporo")).data.first["maori"]).to eq("āporo")
        expect(SearchService.call(search: Search.new(word: "aporo")).data.first["maori"]).to eq("āporo")

        expect(SearchService.call(search: Search.new(word: "rahopūru")).data.first["maori"]).to eq("rahopūru")
        expect(SearchService.call(search: Search.new(word: "rahopuru")).data.first["maori"]).to eq("rahopūru")

        expect(SearchService.call(search: Search.new(word: "pīti")).data.first["maori"]).to eq("pīti")
        expect(SearchService.call(search: Search.new(word: "piti")).data.first["maori"]).to eq("pīti")

        expect(SearchService.call(search: Search.new(word: "parāoa")).data.first["maori"]).to eq("kihu parāoa")
        expect(SearchService.call(search: Search.new(word: "paraoa")).data.first["maori"]).to eq("kihu parāoa")
      end
    end

    context "published date" do
      before(:each) do
        Refined::Search::Data.signs.each do |sign_attrs|
          FactoryBot.create(:sign, :published, sign_attrs)
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
