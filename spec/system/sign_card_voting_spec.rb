require "rails_helper"

RSpec.describe "Sign card voting", type: :system do
  def sign_card
    find(".sign-card", match: :first)
  end

  shared_examples "sign card voting" do
    it "is able to register an agree" do
      within sign_card do
        click_on "Agree"
        expect(page).to have_selector ".sign-card__controls--agreed", text: "1"
      end
    end

    it "is able to deregister an agree" do
      within sign_card do
        click_on "Agree"
        expect(page).to have_selector ".sign-card__controls--agreed", text: "1"
        click_on "Undo agree"
        expect(page).to have_selector ".sign-card__controls--agree", text: "0"
      end
    end

    it "is able to register a disagree" do
      within sign_card do
        click_on "Disagree"
        expect(page).to have_selector ".sign-card__controls--disagreed", text: "1"
      end
    end

    it "is able to deregister a disagree" do
      within sign_card do
        click_on "Disagree"
        expect(page).to have_selector ".sign-card__controls--disagreed", text: "1"
        click_on "Undo disagree"
        expect(page).to have_selector ".sign-card__controls--disagree", text: "0"
      end
    end

    it "is able to switch from agree to disagree" do
      within sign_card do
        click_on "Agree"
        click_on "Disagree"
        expect(page).to have_selector ".sign-card__controls--agree", text: "0", wait: 10
        expect(page).to have_selector ".sign-card__controls--disagreed", text: "1", wait: 10
      end
    end
  end

  describe "Voting" do
    let(:user) { FactoryBot.create(:user, :approved) }
    let!(:sign) { FactoryBot.create(:sign, :published) }

    before do
      sign_in user
      visit root_path
    end

    context "not an approved user" do
      let(:user) { FactoryBot.create(:user) }
      it { expect(page).to have_no_link "Agree" }
      it { expect(page).to have_selector ".sign-card__controls--agree", text: "0" }
    end

    context "without JS" do
      include_examples "sign card voting"
    end

    context "with JS", uses_javascript: true do
      include_examples "sign card voting"
    end
  end
end
