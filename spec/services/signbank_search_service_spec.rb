require "rails_helper"

require "./spec/support/refined_data/search/signs"
require "./spec/support/refined_data/search/signs_with_chocolate"
require "./spec/support/refined_data/search/signs_with_macrons"

RSpec.describe SignbankSearchService, type: :service do
  before { DictionarySign.unscoped.destroy_all }

  describe "search" do
    context "primary word and secondary" do
      before do
        Refined::Search::Signs.default.each do |sign_attrs|
          sign_attrs[:id] = SecureRandom.uuid
          sign_attrs[:gloss_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:word])
          sign_attrs[:minor_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:secondary])
          DictionarySign.create!(sign_attrs.except(:published_at))
        end
      end

      it "returns 0 results if policy scope is none" do
        user = User.new
        results = described_class.new(
          relation: Pundit.policy_scope(user, DictionarySign.none),
          search: Search.new(term: "a")).process

        expect(results.data.count).to be_zero
      end

      it "returns result(s) given a term fragment" do
        expect(search(scoped_relation, term: "a").data.count).to eq 7
        expect(search(scoped_relation, term: "ap").data.count).to eq 2
        expect(search(scoped_relation, term: "app").data.count).to eq 1
        expect(search(scoped_relation, term: "appl").data.count).to eq 1

        expect(search(scoped_relation, term: "p").data.count).to eq 6
        expect(search(scoped_relation, term: "pp").data.count).to eq 1
        expect(search(scoped_relation, term: "ppl").data.count).to eq 1
        expect(search(scoped_relation, term: "pple").data.count).to eq 1

        expect(search(scoped_relation, term: "p").data.count).to eq 6
        expect(search(scoped_relation, term: "pl").data.count).to eq 1
        expect(search(scoped_relation, term: "ple").data.count).to eq 1

        expect(search(scoped_relation, term: "l").data.count).to eq 7
        expect(search(scoped_relation, term: "le").data.count).to eq 2

        expect(search(scoped_relation, term: "e").data.count).to eq 7
      end

      it "returns result(s) given a complete term" do
        expect(search(scoped_relation, term: "pie").data.count).to eq 3
        expect(search(scoped_relation, term: "america").data.count).to eq 3
        expect(search(scoped_relation, term: "risotto").data.count).to eq 2
        expect(search(scoped_relation, term: "england").data.count).to eq 2
        expect(search(scoped_relation, term: "soup").data.count).to eq 2
        expect(search(scoped_relation, term: "cream").data.count).to eq 2
        expect(search(scoped_relation, term: "apple").data.count).to eq 1
      end

      it "returns an exact match first given a complete term" do
        expect(search(scoped_relation, term: "apple")
           .data.pluck(:word, :secondary).flatten.to_s.include?("apple")).to be true
        expect(search(scoped_relation, term: "pie")
          .data.pluck(:word, :secondary).flatten.to_s.include?("pie")).to be true
        expect(search(scoped_relation, term: "banana")
          .data.pluck(:word, :secondary).flatten.to_s.include?("banana")).to be true
        expect(search(scoped_relation, term: "england")
          .data.pluck(:word, :secondary).flatten.to_s.include?("england")).to be true
        expect(search(scoped_relation, term: "cream")
          .data.pluck(:word, :secondary).flatten.to_s.include?("cream")).to be true
        expect(search(scoped_relation, term: "risotto")
          .data.pluck(:word, :secondary).flatten.to_s.include?("risotto")).to be true
        expect(search(scoped_relation, term: "blueberry")
          .data.pluck(:word, :secondary).flatten.to_s.include?("blueberry")).to be true
      end
    end

    context "whitespace" do
      before(:each) do
        Refined::Search::Signs.with_chocolate.each do |sign_attrs|
          sign_attrs[:id] = SecureRandom.uuid
          sign_attrs[:gloss_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:word])
          sign_attrs[:minor_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:secondary])
          DictionarySign.create!(sign_attrs.except(:published_at))
        end
      end

      it "matches exact term" do
        t1 = "chocolate ice cream"
        rs1 = search(scoped_relation, term: t1)
        expect(rs1.data.count && rs1.support[:total]).to eq 1
        expect(rs1.data.pluck(:word).include?(t1)).to be true

        t2 = "chocolate fondant"
        rs2 = search(scoped_relation, term: t2)
        expect(rs2.data.count && rs2.support[:total]).to eq 1
        expect(rs2.data.pluck(:word).include?(t2)).to be true

        t3 = "chocolate souffle"
        rs3 = search(scoped_relation, term: t3)
        expect(rs3.data.count && rs3.support[:total]).to eq 1
        expect(rs3.data.pluck(:word).include?(t3)).to be true
      end

      it "matches partial term" do
        t1 = "chocolate f"
        rs1 = search(scoped_relation, term: t1)
        expect(rs1.data.count && rs1.support[:total]).to eq 5
        expect(rs1.data.pluck(:word)).to eq(
          ["chocolate fingers", "chocolate fish", "chocolate fondant", "chocolate frosting", "chocolate fruit"]
        )

        t2 = "chocolate so"
        rs2 = search(scoped_relation, term: t2)
        expect(rs2.data.count && rs2.support[:total]).to eq 3
        expect(rs2.data.pluck(:word)).to eq(
          ["chocolate sorbet", "chocolate souffle", "chocolate soup"]
        )
      end
    end

    context "macrons" do
      before(:each) do
        Refined::Search::Signs.with_macrons.each do |sign_attrs|
          sign_attrs[:id] = SecureRandom.uuid
          sign_attrs[:gloss_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:word])
          sign_attrs[:minor_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:secondary])
          DictionarySign.create!(sign_attrs.except(:published_at))
        end
      end

      it "return result(s) regardless of macron" do
        expect(search(scoped_relation, term: "āporo").data.first["maori"]).to eq("āporo")

        expect(search(scoped_relation, term: "aporo").data.first["maori"]).to eq("āporo")

        expect(search(scoped_relation, term: "rahopūru").data.first["maori"]).to eq("rahopūru")

        expect(search(scoped_relation, term: "rahopuru").data.first["maori"]).to eq("rahopūru")

        expect(search(scoped_relation, term: "pīti").data.first["maori"]).to eq("pīti")

        expect(search(scoped_relation, term: "piti").data.first["maori"]).to eq("pīti")

        expect(search(scoped_relation, term: "parāoa").data.first["maori"]).to eq("kihu parāoa")

        expect(search(scoped_relation, term: "paraoa").data.first["maori"]).to eq("kihu parāoa")
      end
    end

    context "total" do
      context "less than 10 results" do
        before(:each) do
          Refined::Search::Signs.default.each do |sign_attrs|
            sign_attrs[:id] = SecureRandom.uuid
            sign_attrs[:gloss_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:word])
            sign_attrs[:minor_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:secondary])
            DictionarySign.create!(sign_attrs.except(:published_at))
          end
        end

        it "returns result(s) total" do
          rs1 = search(scoped_relation, term: "a")
          expect(rs1.data.count).to eq rs1.support[:total]

          rs2 = search(scoped_relation, term: "ap")
          expect(rs2.data.count).to eq rs2.support[:total]

          rs3 = search(scoped_relation, term: "app")
          expect(rs3.data.count).to eq rs3.support[:total]

          rs4 = search(scoped_relation, term: "p")
          expect(rs4.data.count).to eq rs4.support[:total]

          rs5 = search(scoped_relation, term: "pp")
          expect(rs5.data.count).to eq rs5.support[:total]

          rs6 = search(scoped_relation, term: "l")
          expect(rs6.data.count).to eq rs6.support[:total]

          rs7 = search(scoped_relation, term: "le")
          expect(rs7.data.count).to eq rs7.support[:total]

          rs8 = search(scoped_relation, term: "e")
          expect(rs8.data.count).to eq rs8.support[:total]

          rs9 = search(scoped_relation, term: "123")
          expect(rs9.data.count).to eq rs9.support[:total]

          rs10 = search(scoped_relation, term: "#$%")
          expect(rs10.data.count).to eq rs10.support[:total]
        end
      end

      context "more than 10 results" do
        before(:each) do
          Refined::Search::Signs.with_chocolate.each do |sign_attrs|
            sign_attrs[:id] = SecureRandom.uuid
            sign_attrs[:gloss_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:word])
            sign_attrs[:minor_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:secondary])
            DictionarySign.create!(sign_attrs.except(:published_at))
          end
        end

        it "returns page default limit and result(s) total" do
          rs1 = search(scoped_relation, term: "ch")
          expect(rs1.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs1.support[:total]).to eq 20

          rs2 = search(scoped_relation, term: "oco")
          expect(rs2.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs2.support[:total]).to eq 20

          rs3 = search(scoped_relation, term: "choc")
          expect(rs3.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs3.support[:total]).to eq 20

          rs4 = search(scoped_relation, term: "a")
          expect(rs4.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs4.support[:total]).to eq 20

          rs5 = search(scoped_relation, term: "chocolate")
          expect(rs5.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs5.support[:total]).to eq 20

          rs6 = search(scoped_relation, term: "ate")
          expect(rs6.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs6.support[:total]).to eq 20
        end
      end
    end

    describe "sorting" do
      before(:each) do
        Refined::Search::Signs.default.each do |sign_attrs|
          sign_attrs[:id] = SecureRandom.uuid
          sign_attrs[:gloss_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:word])
          sign_attrs[:minor_normalized] = ActiveSupport::Inflector.transliterate(sign_attrs[:secondary])
          DictionarySign.create!(sign_attrs.except(:published_at))
        end
      end

      context "by recent" do
        example "breaks due to lack of published_at" do
          # We don't support this sort order for this type of search
          # In SearchController, we alias this and 'popular' to ordering
          # by word in ascending order
          expect do
            search(scoped_relation, term: "a", sort: "recent").data.to_a
          end.to raise_error ActiveRecord::StatementInvalid
        end
      end

      context "by popular" do
        example "breaks due to lack of activity" do
          # We don't support this sort order for this type of search
          # In SearchController, we alias this and 'recent' to ordering
          # by word in ascending order
          expect do
            search(scoped_relation, term: "a", sort: "popular").data.to_a
          end.to raise_error ActiveRecord::StatementInvalid
        end
      end

      context "by relevance" do
        example "be in the expected order" do
          words = search(scoped_relation, term: "ap", sort: "relevant")
                  .data.pluck("word")

          expect(words.sort).to eq words
        end
      end

      context "alphabetically ascending" do
        example "be in the expected order" do
          words = search(scoped_relation, term: "a", sort: "alpha_asc")
                  .data.pluck("word")

          expect(words.sort).to eq words
        end
      end

      context "alphabetically descending" do
        example "be in the expected order" do
          words = search(scoped_relation, term: "a", sort: "alpha_desc")
                  .data.pluck("word")

          expect(words.sort.reverse).to eq words
        end
      end
    end
  end

  private

  def search(relation, params)
    params.reverse_merge!(sort: "relevant")
    described_class.new(relation: relation, search: Search.new(params)).process
  end

  def scoped_relation
    DictionarySign.all
  end
end
