require "rails_helper"

RSpec.describe "My Signs", type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:signs) { FactoryBot.create_list(:sign, 5, contributor: user) }
  let!(:unowned_sign) { FactoryBot.create(:sign) }
  let(:auth) { AuthenticateFeature.new(user) }

  before do
    auth.sign_in
    within ".sidebar--inside-grid" do
      click_on "My signs"
    end
  end

  it "has the expected page title" do
    expect(page).to have_title "My signs – NZSL Share"
  end

  describe "header" do
    it "is titled" do
      expect(page).to have_selector "h1", text: "My signs"
    end
  end

  describe "signs" do
    it "includes the expected signs" do
      signs.each do |sign|
        expect(page).to have_selector ".sign-card .sign-card__title", text: sign.word
      end
    end

    it "includes expected sign status and description" do
      sign_card = page.find("#sign_status", match: :prefer_exact)
      expect(sign_card.text).to eq "Private"
      expect(sign_card["title"]).to eq(I18n.t!("signs.personal.description"))
    end

    it "includes 'Folders' button" do
      expect(page).to have_button "Folders"
    end

    it "doesn't include unexpected signs" do
      expect(page).to have_no_selector ".sign-card .sign-card__title", text: unowned_sign.word
    end
  end
end
