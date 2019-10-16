require "rails_helper"

RSpec.describe "Topics", type: :system do
  let!(:topics) { FactoryBot.create_list(:topic, 5, :with_associated_signs) }

  describe "listing" do
    before { visit topics_path }

    it "has a list of topic headings" do
      topics.each { |t| expect(page).to have_selector("h4", text: t.name) }
    end
  end

  describe "show" do
    let(:topic) { topics.first }
    subject { page }
    before { visit topic_path(topic) }

    it { is_expected.to have_content topic.name }
    it { is_expected.to have_selector(".sign-card", count: topic.signs.count) }
  end
end
