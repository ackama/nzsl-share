require "rails_helper"

require "./spec/support/refined_data/search/signs"
require "./spec/support/refined_data/search/signs_with_chocolate"

RSpec.describe PublicSignService, type: :service do
  let(:user) { FactoryBot.create(:user) }

  describe "public signs" do
    context "scope" do
      before(:each) do
        Refined::Search::Signs.default.each do |sign_attrs|
          FactoryBot.create(:sign, :published, sign_attrs)
        end
      end

      it "returns 0 results if policy scope is none" do
        expect(search(Pundit.policy_scope(user, Sign.none), sort: "alpha_asc").data.count).to eq 0
      end

      it "does not include non-published results" do
        expect do
          FactoryBot.create(:sign, :submitted, Refined::Search::Signs.default.first)
        end.not_to change(search(scoped_relation, sort: "alpha_asc").data, :count)
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
          rs1 = search(scoped_relation, sort: "alpha_asc")
          expect(rs1.data.count).to eq rs1.support[:total]
        end
      end

      context "more than 10 results" do
        before(:each) do
          Refined::Search::Signs.with_chocolate.each do |sign_attrs|
            FactoryBot.create(:sign, :published, sign_attrs)
          end
        end

        it "returns page default limit and result(s) total" do
          rs1 = search(scoped_relation, sort: "alpha_asc")
          expect(rs1.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs1.support[:total]).to eq 20
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
          publish_dates = search(scoped_relation, sort: "recent")
                          .data.pluck("published_at")

          expect(publish_dates.sort.reverse).to eq publish_dates
        end
      end

      context "by relevance" do
        example "be in the expected order" do
          words = search(scoped_relation, sort: "relevant")
                  .data.pluck("word")

          expect(words.sort).to eq words
        end
      end

      context "alphabetically ascending" do
        example "be in the expected order" do
          words = search(scoped_relation, sort: "alpha_asc")
                  .data.pluck("word")

          expect(words.sort).to eq words
        end
      end

      context "alphabetically descending" do
        example "be in the expected order" do
          words = search(scoped_relation, sort: "alpha_desc")
                  .data.pluck("word")

          expect(words.sort.reverse).to eq words
        end
      end

      context "most popular" do
        example "be in the expected order" do
          Sign.all.each do |sign|
            rand(1..10).times { sign.activities << FactoryBot.build(:sign_activity) }
            sign.save
          end

          signs = PublicSignService.new(
            relation: scoped_relation,
            search: Search.new(sort: "popular")
          ).process.data

          # returns a collection of agreed counts in order i.e [1, 2, 3, 3, 4, 6]
          agrees = signs.inject([]) do |arr, sign|
            arr << sign.activities.where(key: "agree").count
          end - [0]

          # compare the counts with what the search service returned, the order
          # 'should' match
          agrees.each_with_index do |agree, idx|
            expect(signs[idx].activities.where(key: "agree").count).to eq(agree)
          end
        end
      end
    end
  end

  private

  def search(relation, params)
    PublicSignService.new(search: Search.new(params), relation: relation).process
  end

  def scoped_relation
    Pundit.policy_scope(user, Sign)
  end
end
