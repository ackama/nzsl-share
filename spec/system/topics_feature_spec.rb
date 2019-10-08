require "rails_helper"

RSpec.describe "Topics", type: :system do
  let!(:topics) { FactoryBot.create_list(:topic, 5, :with_associated_signs) }

  describe "listing" do
    before { visit topics_path }

    it "has a list of topic headings" do
      topics.each { |t| expect(page).to have_selector("h2", text: t.name) }
    end

    it "shows a preview of topics under each heading" do
      expect(page).to have_selector(".sign-card", count: 20) # 4 preview signs, 5 topics
    end
  end
end
