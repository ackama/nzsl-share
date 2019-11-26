require "rails_helper"

require "./spec/support/refined_data/search/signs"
require "./spec/support/refined_data/search/signs_with_chocolate"
require "./spec/support/refined_data/search/signs_with_macrons"

RSpec.describe SearchService, type: :service do
  let(:user) { FactoryBot.create(:user) }

  describe "search" do
    context "primary word and secondary" do
      before(:each) do
        Refined::Search::Signs.default.each do |sign_attrs|
          sign_attrs[:status] ||= "published"
          sign_attrs[:conditions_accepted] ||= true
          FactoryBot.create(:sign, sign_attrs)
        end
      end

      it "returns 0 results if policy scope is none" do
        expect(
          SearchService.call(relation: Pundit.policy_scope(user, Sign.none), search: Search.new(term: "a")).data.count
        ).to eq 0
      end

      it "returns result(s) given a term fragment" do
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "a")).data.count).to eq 7
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "ap")).data.count).to eq 2
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "app")).data.count).to eq 1
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "appl")).data.count).to eq 1

        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "p")).data.count).to eq 6
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "pp")).data.count).to eq 1
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "ppl")).data.count).to eq 1
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "pple")).data.count).to eq 1

        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "p")).data.count).to eq 6
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "pl")).data.count).to eq 1
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "ple")).data.count).to eq 1

        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "l")).data.count).to eq 7
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "le")).data.count).to eq 2

        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "e")).data.count).to eq 7
      end

      it "returns result(s) given a complete term" do
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "pie")).data.count).to eq 3
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "america")).data.count).to eq 3
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "risotto")).data.count).to eq 2
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "england")).data.count).to eq 2
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "soup")).data.count).to eq 2
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "cream")).data.count).to eq 2
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "apple")).data.count).to eq 1
      end

      it "returns an exact match first given a complete term" do
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "apple"))
           .data.pluck(:word, :secondary).flatten.to_s.include?("apple")).to be true
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "pie"))
          .data.pluck(:word, :secondary).flatten.to_s.include?("pie")).to be true
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "banana"))
          .data.pluck(:word, :secondary).flatten.to_s.include?("banana")).to be true
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "england"))
          .data.pluck(:word, :secondary).flatten.to_s.include?("england")).to be true
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "cream"))
          .data.pluck(:word, :secondary).flatten.to_s.include?("cream")).to be true
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "risotto"))
          .data.pluck(:word, :secondary).flatten.to_s.include?("risotto")).to be true
        expect(SearchService.call(relation: scoped_relation, search: Search.new(term: "blueberry"))
          .data.pluck(:word, :secondary).flatten.to_s.include?("blueberry")).to be true
      end
    end

    context "whitespace" do
      before(:each) do
        Refined::Search::Signs.with_chocolate.each do |sign_attrs|
          sign_attrs[:status] ||= "published"
          sign_attrs[:conditions_accepted] = true

          FactoryBot.create(:sign, sign_attrs)
        end
      end

      it "matches exact term" do
        t1 = "chocolate ice cream"
        rs1 = SearchService.call(relation: scoped_relation, search: Search.new(term: t1))
        expect(rs1.data.count && rs1.support[:total]).to eq 1
        expect(rs1.data.pluck(:word).include?(t1)).to be true

        t2 = "chocolate fondant"
        rs2 = SearchService.call(relation: scoped_relation, search: Search.new(term: t2))
        expect(rs2.data.count && rs2.support[:total]).to eq 1
        expect(rs2.data.pluck(:word).include?(t2)).to be true

        t3 = "chocolate souffle"
        rs3 = SearchService.call(relation: scoped_relation, search: Search.new(term: t3))
        expect(rs3.data.count && rs3.support[:total]).to eq 1
        expect(rs3.data.pluck(:word).include?(t3)).to be true
      end

      it "matches partial term" do
        t1 = "chocolate f"
        rs1 = SearchService.call(relation: scoped_relation, search: Search.new(term: t1))
        expect(rs1.data.count && rs1.support[:total]).to eq 5
        expect(rs1.data.pluck(:word)).to eq(
          ["chocolate fingers", "chocolate fish", "chocolate fondant", "chocolate frosting", "chocolate fruit"]
        )

        t2 = "chocolate so"
        rs2 = SearchService.call(relation: scoped_relation, search: Search.new(term: t2))
        expect(rs2.data.count && rs2.support[:total]).to eq 3
        expect(rs2.data.pluck(:word)).to eq(
          ["chocolate sorbet", "chocolate souffle", "chocolate soup"]
        )
      end
    end

    context "macrons" do
      before(:each) do
        Refined::Search::Signs.with_macrons.each do |sign_attrs|
          sign_attrs[:status] ||= "published"
          sign_attrs[:conditions_accepted] = true

          FactoryBot.create(:sign, sign_attrs)
        end
      end

      it "return result(s) regardless of macron" do
        expect(
          SearchService.call(
            relation: scoped_relation, search: Search.new(term: "āporo")).data.first["maori"]
        ).to eq("āporo")

        expect(
          SearchService.call(
            relation: scoped_relation, search: Search.new(term: "aporo")).data.first["maori"]
        ).to eq("āporo")

        expect(
          SearchService.call(
            relation: scoped_relation, search: Search.new(term: "rahopūru")).data.first["maori"]
        ).to eq("rahopūru")

        expect(
          SearchService.call(relation: scoped_relation, search: Search.new(term: "rahopuru")).data.first["maori"]
        ).to eq("rahopūru")

        expect(
          SearchService.call(relation: scoped_relation, search: Search.new(term: "pīti")).data.first["maori"]
        ).to eq("pīti")

        expect(
          SearchService.call(relation: scoped_relation, search: Search.new(term: "piti")).data.first["maori"]
        ).to eq("pīti")

        expect(
          SearchService.call(relation: scoped_relation, search: Search.new(term: "parāoa")).data.first["maori"]
        ).to eq("kihu parāoa")

        expect(
          SearchService.call(relation: scoped_relation, search: Search.new(term: "paraoa")).data.first["maori"]
        ).to eq("kihu parāoa")
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
          rs1 = SearchService.call(relation: scoped_relation, search: Search.new(term: "a"))
          expect(rs1.data.count).to eq rs1.support[:total]

          rs2 = SearchService.call(relation: scoped_relation, search: Search.new(term: "ap"))
          expect(rs2.data.count).to eq rs2.support[:total]

          rs3 = SearchService.call(relation: scoped_relation, search: Search.new(term: "app"))
          expect(rs3.data.count).to eq rs3.support[:total]

          rs4 = SearchService.call(relation: scoped_relation, search: Search.new(term: "p"))
          expect(rs4.data.count).to eq rs4.support[:total]

          rs5 = SearchService.call(relation: scoped_relation, search: Search.new(term: "pp"))
          expect(rs5.data.count).to eq rs5.support[:total]

          rs6 = SearchService.call(relation: scoped_relation, search: Search.new(term: "l"))
          expect(rs6.data.count).to eq rs6.support[:total]

          rs7 = SearchService.call(relation: scoped_relation, search: Search.new(term: "le"))
          expect(rs7.data.count).to eq rs7.support[:total]

          rs8 = SearchService.call(relation: scoped_relation, search: Search.new(term: "e"))
          expect(rs8.data.count).to eq rs8.support[:total]

          rs9 = SearchService.call(relation: scoped_relation, search: Search.new(term: "123"))
          expect(rs9.data.count).to eq rs9.support[:total]

          rs10 = SearchService.call(relation: scoped_relation, search: Search.new(term: "#$%"))
          expect(rs10.data.count).to eq rs10.support[:total]
        end
      end

      context "more than 10 results" do
        before(:each) do
          Refined::Search::Signs.with_chocolate.each do |sign_attrs|
            sign_attrs[:status] ||= "published"
            sign_attrs[:conditions_accepted] = true

            FactoryBot.create(:sign, sign_attrs)
          end
        end

        it "returns page default limit and result(s) total" do
          rs1 = SearchService.call(relation: scoped_relation, search: Search.new(term: "ch"))
          expect(rs1.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs1.support[:total]).to eq 20

          rs2 = SearchService.call(relation: scoped_relation, search: Search.new(term: "oco"))
          expect(rs2.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs2.support[:total]).to eq 20

          rs3 = SearchService.call(relation: scoped_relation, search: Search.new(term: "choc"))
          expect(rs3.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs3.support[:total]).to eq 20

          rs4 = SearchService.call(relation: scoped_relation, search: Search.new(term: "a"))
          expect(rs4.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs4.support[:total]).to eq 20

          rs5 = SearchService.call(relation: scoped_relation, search: Search.new(term: "chocolate"))
          expect(rs5.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs5.support[:total]).to eq 20

          rs6 = SearchService.call(relation: scoped_relation, search: Search.new(term: "ate"))
          expect(rs6.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs6.support[:total]).to eq 20
        end
      end
    end

    describe "sorting" do
      before(:each) do
        Refined::Search::Signs.default.each do |sign_attrs|
          FactoryBot.create(:sign, :published, sign_attrs)
        end
      end

      context "by recent" do
        example "be in the expected order" do
          publish_dates = SearchService.call(relation: scoped_relation, search: Search.new(term: "a", sort: "recent"))
                                       .data.map { |hsh| hsh["published_at"] }

          expect(publish_dates.sort.reverse).to eq publish_dates
        end
      end

      context "by relevance" do
        example "be in the expected order" do
          words = SearchService.call(relation: scoped_relation, search: Search.new(term: "ap", sort: "relevant"))
                               .data.map { |hsh| hsh["word"] }

          expect(words.sort).to eq words
        end
      end

      context "alphabetically ascending" do
        example "be in the expected order" do
          words = SearchService.call(relation: scoped_relation, search: Search.new(term: "a", sort: "alpha_asc"))
                               .data.map { |hsh| hsh["word"] }

          expect(words.sort).to eq words
        end
      end

      context "alphabetically descending" do
        example "be in the expected order" do
          words = SearchService.call(relation: scoped_relation, search: Search.new(term: "a", sort: "alpha_desc"))
                               .data.map { |hsh| hsh["word"] }

          expect(words.sort.reverse).to eq words
        end
      end
    end
  end

  private

  def scoped_relation
    Pundit.policy_scope(user, Sign)
  end
end
