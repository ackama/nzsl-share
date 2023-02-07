require "rails_helper"

RSpec.describe "Searching for signs" do
  context "with full results" do
    before do
      DictionarySign.unscoped.destroy_all
      Array.new(6) { DictionarySign.create!(id: SecureRandom.uuid, gloss_normalized: "a") }
      FactoryBot.create_list(:sign, 5, :published, word: "a")
      submit_search("a")
    end

    it "shows the expected results" do
      # We only show a preview of official signs
      expect(page).to have_selector "#official-signs .sign-card", count: 4
      expect(page).to have_selector "#community-signs .sign-card", count: 5
    end
  end

  context "with only Signbank results" do
    before do
      FactoryBot.create_list(:dictionary_sign, 6, word: "a")
      submit_search("a")
    end

    it "shows the expected results" do
      # We only show a preview of official signs
      expect(page).to have_selector "#official-signs .sign-card", count: 4
      expect(page).to have_no_selector "#community-signs"
    end
  end

  context "with only Share results" do
    before do
      DictionarySign.unscoped.destroy_all
      FactoryBot.create_list(:sign, 5, :published, word: "a")
      submit_search("a")
    end

    it "shows the expected results" do
      # We only show a preview of official signs
      expect(page).to have_no_selector "#official-signs"
      expect(page).to have_selector "#community-signs .sign-card", count: 5
    end
  end

  private

  def submit_search(term)
    visit root_path
    form = find(".hero-unit form.search-bar")
    form.fill_in "Search signs", with: term

    # Artificially submit the form. Normally the browser does this, but
    # Rack::Test can't.
    Capybara::RackTest::Form.new(page.driver, form.native).submit({})
  end
end
