require "rails_helper"

RSpec.describe "Topics", type: :system do
  let!(:topics) { FactoryBot.create_list(:topic, 5, :with_associated_signs) }

  describe "listing" do
    before { visit topics_path }

    it "has a list of topic headings" do
      topics.each { |t| expect(page).to have_selector("p", text: t.name) }
    end

    it "has the correct page title" do
      expect(page).to have_title "Topics – NZSL Share"
    end

    it "has a link to view all signs" do
      expect(page).to have_link "See all signs", href: public_signs_path
    end
  end

  describe "show" do
    let(:topic) { topics.first }
    let!(:private_sign) { FactoryBot.create(:sign, topics: [topic]) }
    let!(:submitted_sign) { FactoryBot.create(:sign, :submitted, topics: [topic]) }

    subject { page }
    before { visit topic_path(topic) }

    it { is_expected.to have_title "#{topic.name} – NZSL Share" }
    it { is_expected.to have_content topic.name }
    it "shows all published signs" do
      expect(topic.signs.count - 2).to eq topic.signs.published.count
      is_expected.to have_selector(".sign-card", count: topic.signs.published.count)
    end
    it "can click through to the sign card show page" do
      sign = topic.signs.first
      click_on sign.word
      expect(current_path).to eq sign_path(sign)
    end
  end
end
