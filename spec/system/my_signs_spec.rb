require "rails_helper"

RSpec.describe "My Signs", type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:signs) { FactoryBot.create_list(:sign, 5, contributor: user) }
  let!(:unowned_sign) { FactoryBot.create(:sign) }

  before do
    sign_in user
    visit user_signs_path
  end

  it "can be accessed via the sidebar" do
    visit root_path

    within ".sidebar--inside-grid" do
      click_on "My signs"
    end

    expect(page).to have_current_path(user_signs_path)
  end

  it "has the expected browser page title" do
    expect(page).to have_title "My signs – NZSL Share"
  end

  it "has the expected page title" do
    expect(page).to have_selector "h1", text: "My signs"
  end

  describe "signs" do
    it "includes the expected signs" do
      signs.each do |sign|
        expect(page).to have_selector ".sign-table__title", text: sign.word
      end
    end

    it "includes expected sign status and description" do
      sign_card = page.find(".sign-table__status", match: :prefer_exact)
      expect(sign_card.text).to eq "Private"
      expect(sign_card["title"]).to eq(I18n.t!("signs.personal.description"))
    end

    it "doesn't include unexpected signs" do
      expect(page).to have_no_selector ".sign-table__title", text: unowned_sign.word
    end
  end

  describe "sorting specs" do
    describe "when the specs are to be sorted in alphabetical order" do
      let!(:signs) do
        [
          FactoryBot.create(:sign, word: "BBBBBBBBBB", contributor: user),
          FactoryBot.create(:sign, word: "CCCCCCCCCC", contributor: user),
          FactoryBot.create(:sign, word: "AAAAAAAAAA", contributor: user)
        ]
      end

      it "shows signs in alphabetical order when set to sort by alphabetical order" do
        visit user_signs_path(sort_by: "alphabetical")

        expect(page.all(".sign-table__title").collect(&:text)).to eq(%w[AAAAAAAAAA BBBBBBBBBB CCCCCCCCCC])
      end

      it "shows signs in alphabetical order when no sort param is provided" do
        visit user_signs_path

        expect(page.all(".sign-table__title").collect(&:text)).to eq(%w[AAAAAAAAAA BBBBBBBBBB CCCCCCCCCC])
      end

      it "shows signs in alphabetical order when an invalid sort param is provided" do
        visit user_signs_path(sort_by: "pineapple_pizza")

        expect(page.all(".sign-table__title").collect(&:text)).to eq(%w[AAAAAAAAAA BBBBBBBBBB CCCCCCCCCC])
      end

      it "sorts by alphabetical order when the dropdown is set to sort by alphabetical order", uses_javascript: true do
        visit user_signs_path(sort_by: "most_recent")
        expect(page.all(".sign-table__title").collect(&:text)).not_to eq(%w[AAAAAAAAAA BBBBBBBBBB CCCCCCCCCC])
        select "Alphabetical", from: "Sort by"
        expect(page.all(".sign-table__title").collect(&:text)).to eq(%w[AAAAAAAAAA BBBBBBBBBB CCCCCCCCCC])
      end
    end

    describe "when the specs are to be sorted by most recent" do
      let!(:signs) do
        [
          FactoryBot.create(:sign, word: "OLD", contributor: user, created_at: 7.days.ago),
          FactoryBot.create(:sign, word: "CURRENT", contributor: user),
          FactoryBot.create(:sign, word: "NEW", contributor: user, created_at: 7.days.from_now)
        ]
      end

      it "shows signs in date order when set to sort by most recent" do
        visit user_signs_path(sort_by: "most_recent")

        expect(page.all(".sign-table__title").collect(&:text)).to eq(%w[NEW CURRENT OLD])
      end

      it "sorts by most recent when the dropdown is set to sort by most recent", uses_javascript: true do
        visit user_signs_path(sort_by: "alphabetical")
        expect(page.all(".sign-table__title").collect(&:text)).not_to eq(%w[NEW CURRENT OLD])
        select "Most recent", from: "Sort by"
        expect(page.all(".sign-table__title").collect(&:text)).to eq(%w[NEW CURRENT OLD])
      end
    end
  end
end
