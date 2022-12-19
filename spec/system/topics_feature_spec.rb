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

    it "has a link to view uncategorised signs" do
      expect(page).to have_link Topic::NO_TOPIC_DESCRIPTION, href: uncategorised_topics_path
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

  describe "uncategorised" do
    it "can be navigated to" do
      visit root_path
      within(".hero-unit") { click_on("Browse Topics") }
      click_on Topic::NO_TOPIC_DESCRIPTION
      expect(page).to have_selector "h1", text: Topic::NO_TOPIC_DESCRIPTION
    end

    it "has the expected sign cards" do
      uncategorised_private_sign = FactoryBot.create(:sign)
      uncategorised_private_sign.sign_topics.destroy_all
      uncategorised_published_sign = FactoryBot.create(:sign, :published)
      uncategorised_published_sign.sign_topics.destroy_all

      categorised_private_sign = FactoryBot.create(:sign, contributor:
        uncategorised_private_sign.contributor)

      auth = AuthenticateFeature.new(categorised_private_sign.contributor)
      auth.sign_in

      visit uncategorised_topics_path
      expect(page).to have_selector(".sign-card#card_sign_#{uncategorised_published_sign.to_param}")
      expect(page).to have_selector(".sign-card#card_sign_#{uncategorised_private_sign.to_param}")
      expect(page).to have_no_selector(".sign-card#card_sign_#{categorised_private_sign.to_param}")

      auth.sign_out
      visit uncategorised_topics_path
      expect(page).to have_selector(".sign-card#card_sign_#{uncategorised_published_sign.to_param}")
      expect(page).to have_no_selector(".sign-card#card_sign_#{uncategorised_private_sign.to_param}")
      expect(page).to have_no_selector(".sign-card#card_sign_#{categorised_private_sign.to_param}")
    end
  end
end
