require "rails_helper"

require "./spec/support/refined_data/search/signs"
require "./spec/support/refined_data/search/signs_with_chocolate"
require "./spec/support/refined_data/search/signs_with_macrons"

RSpec.describe SearchService, type: :service do
  describe "search" do
    context "english and secondary" do
      before(:each) do
        Refined::Search::Signs.default.each do |sign_attrs|
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
        Refined::Search::Signs.with_macrons.each do |sign_attrs|
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

    context "total" do
      context "less than 10 results" do
        before(:each) do
          Refined::Search::Signs.default.each do |sign_attrs|
            FactoryBot.create(:sign, sign_attrs)
          end
        end

        it "returns result(s) total" do
          rs1 = SearchService.call(search: Search.new(word: "a"))
          expect(rs1.data.count).to eq rs1.support[:total]

          rs2 = SearchService.call(search: Search.new(word: "ap"))
          expect(rs2.data.count).to eq rs2.support[:total]

          rs3 = SearchService.call(search: Search.new(word: "app"))
          expect(rs3.data.count).to eq rs3.support[:total]

          rs4 = SearchService.call(search: Search.new(word: "p"))
          expect(rs4.data.count).to eq rs4.support[:total]

          rs5 = SearchService.call(search: Search.new(word: "pp"))
          expect(rs5.data.count).to eq rs5.support[:total]

          rs6 = SearchService.call(search: Search.new(word: "l"))
          expect(rs6.data.count).to eq rs6.support[:total]

          rs7 = SearchService.call(search: Search.new(word: "le"))
          expect(rs7.data.count).to eq rs7.support[:total]

          rs8 = SearchService.call(search: Search.new(word: "e"))
          expect(rs8.data.count).to eq rs8.support[:total]

          rs9 = SearchService.call(search: Search.new(word: "123"))
          expect(rs9.data.count).to eq rs9.support[:total]

          rs10 = SearchService.call(search: Search.new(word: "#$%"))
          expect(rs10.data.count).to eq rs10.support[:total]
        end
      end

      context "more than 10 results" do
        before(:each) do
          Refined::Search::Signs.with_chocolate.each do |sign_attrs|
            FactoryBot.create(:sign, sign_attrs)
          end
        end

        it "returns page default limit and result(s) total" do
          rs1 = SearchService.call(search: Search.new(word: "ch"))
          expect(rs1.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs1.support[:total]).to eq 20

          rs2 = SearchService.call(search: Search.new(word: "oco"))
          expect(rs2.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs2.support[:total]).to eq 20

          rs3 = SearchService.call(search: Search.new(word: "choc"))
          expect(rs3.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs3.support[:total]).to eq 20

          rs4 = SearchService.call(search: Search.new(word: "a"))
          expect(rs4.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs4.support[:total]).to eq 20

          rs5 = SearchService.call(search: Search.new(word: "chocolate"))
          expect(rs5.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs5.support[:total]).to eq 20

          rs6 = SearchService.call(search: Search.new(word: "ate"))
          expect(rs6.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs6.support[:total]).to eq 20
        end
      end
    end

    context "published date" do
      before(:each) do
        Refined::Search::Signs.default.each do |sign_attrs|
          FactoryBot.create(:sign, :published, sign_attrs)
        end
      end

      it "orders ascending" do
        rs1 = SearchService.call(search: Search.new(word: "a", order: { published: "ASC" }))
                           .data.map { |hsh| hsh["published_at"] }

        rs2 = SearchService.call(search: Search.new(word: "a", order: { published: "DESC" }))
                           .data.map { |hsh| hsh["published_at"] }.sort

        expect(rs1 == rs2).to be true
      end

      it "orders descending" do
        rs1 = SearchService.call(search: Search.new(word: "a", order: { published: "DESC" }))
                           .data.map { |hsh| hsh["published_at"] }

        rs2 = SearchService.call(search: Search.new(word: "a", order: { published: "ASC" }))
                           .data.map { |hsh| hsh["published_at"] }.sort.reverse

        expect(rs1 == rs2).to be true
      end
    end
  end
end
