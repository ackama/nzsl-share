require "rails_helper"

RSpec.describe TopicSignService, type: :service do
  let(:user) { FactoryBot.create(:user) }
  let!(:topic) { FactoryBot.create(:topic, :with_35_associated_signs) }

  describe "topic signs" do
    context "total" do
      context "more than 10 results" do
        it "returns page default limit and result(s) total" do
          rs1 = search(scoped_relation, sort: "alpha_asc")
          expect(rs1.data.count).to eq Search::DEFAULT_LIMIT
          expect(rs1.support[:total]).to eq 35
        end
      end
    end

    describe "uncategorised" do
      let!(:sign) { FactoryBot.create(:sign) }

      it "shows only signs without topics" do
        sign.sign_topics.destroy_all

        signs = TopicSignService.new(
          relation: Sign,
          search: Search.new,
          topic: Topic.new(name: Topic::NO_TOPIC_DESCRIPTION)
        ).process.data

        expect(signs.length).to eq(1)
        expect(signs.first.id).to eq(sign.id)
      end
    end

    describe "sorting" do
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
          Sign.find_each do |sign|
            rand(1..10).times { sign.activities << FactoryBot.build(:sign_activity) }
            sign.save
          end

          signs = TopicSignService.new(
            relation: scoped_relation,
            search: Search.new(sort: "popular"),
            topic:
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
    TopicSignService.new(search: Search.new(params), relation:, topic:).process
  end

  def scoped_relation
    Pundit.policy_scope(user, Sign)
  end
end
