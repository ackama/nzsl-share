require "rails_helper"

RSpec.describe "Sign index", system: true do
  let(:user) { FactoryBot.create(:user, :approved) }

  before do
    sign_in user
  end

  describe "when the specs are to be sorted in alphabetical order" do
    before do
      FactoryBot.create(:sign, word: "BBBBBBBBBB", contributor: user)
      FactoryBot.create(:sign, word: "CCCCCCCCCC", contributor: user)
      FactoryBot.create(:sign, word: "AAAAAAAAAA", contributor: user)
    end

    it "shows signs in alphabetical order when set to sort by alphabetical order" do
      visit user_signs_path(sort_by: "alphabetical")

      expect(page.all(".sign-card__title").collect(&:text)).to eq(%w[AAAAAAAAAA BBBBBBBBBB CCCCCCCCCC])
    end

    it "shows signs in alphabetical order when no sort param is provided" do
      visit user_signs_path

      expect(page.all(".sign-card__title").collect(&:text)).to eq(%w[AAAAAAAAAA BBBBBBBBBB CCCCCCCCCC])
    end

    it "shows signs in alphabetical order when an invalid sort param is provided" do
      visit user_signs_path(sort_by: "pineapple_pizza")

      expect(page.all(".sign-card__title").collect(&:text)).to eq(%w[AAAAAAAAAA BBBBBBBBBB CCCCCCCCCC])
    end

    it "sorts by alphabetical order when the dropdown is set to sort by alphabetical order", uses_javascript: true do
      visit user_signs_path(sort_by: "most_recent")
      expect(page.all(".sign-card__title").collect(&:text)).not_to eq(%w[AAAAAAAAAA BBBBBBBBBB CCCCCCCCCC])
      select "Alphabetical", from: "Sort by"
      expect(page.all(".sign-card__title").collect(&:text)).to eq(%w[AAAAAAAAAA BBBBBBBBBB CCCCCCCCCC])
    end
  end

  describe "when the specs are to be sorted by most recent" do
    before do
      FactoryBot.create(:sign, word: "OLD", contributor: user, created_at: 7.days.ago)
      FactoryBot.create(:sign, word: "CURRENT", contributor: user)
      FactoryBot.create(:sign, word: "NEW", contributor: user, created_at: 7.days.from_now)
    end

    it "shows signs in date order when set to sort by most recent" do
      visit user_signs_path(sort_by: "most_recent")

      expect(page.all(".sign-card__title").collect(&:text)).to eq(%w[NEW CURRENT OLD])
    end

    it "sorts by most recent when the dropdown is set to sort by most recent", uses_javascript: true do
      visit user_signs_path(sort_by: "alphabetical")
      expect(page.all(".sign-card__title").collect(&:text)).not_to eq(%w[NEW CURRENT OLD])
      select "Most recent", from: "Sort by"
      expect(page.all(".sign-card__title").collect(&:text)).to eq(%w[NEW CURRENT OLD])
    end
  end
end
