require "rails_helper"

RSpec.describe "Profile page", type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let(:auth) { AuthenticateFeature.new(user) }

  context "viewing" do
    before { visit user_path(user) }

    it "shows username" do
      within ".form" do
        expect(page).to have_content(user.username)
      end
    end

    it "shows bio" do
      within ".form" do
        expect(page).to have_content(user.bio)
      end
    end

    it "shows profile picture" do
      within ".form" do
        expect(page).to have_selector(".avatar")
      end
    end
  end

  context "editing" do
    before { auth.sign_in }

    it "nav links to edit profile page", uses_javascript: true do
      visit root_path
      within ".navigation__item--account" do
        click_on user.username
      end
      click_on "Edit my profile"
      expect(page).to have_current_path("/users/edit")
    end

    it "can edit my details successfully" do
      visit edit_user_registration_path(user)
      expect(page).to have_content "Edit profile"
      fill_in "Bio", with: "My new biography"
      fill_in "Current password", with: user.password
      click_on "Update"
      expect(page).to have_content I18n.t("devise.registrations.updated")
    end

    it "displays errors when I don't confirm my password" do
      visit edit_user_registration_path(user)
      fill_in "Bio", with: "My new biography"
      click_on "Update"
      expect(page).to have_css ".invalid"
    end

    context "approved member status" do
      let!(:user) { FactoryBot.create(:user, approved_user_application: application) }

      before { visit edit_user_registration_path(user) }
      context "have not yet applied" do
        let(:application) { nil }
        it { expect(page).to have_link "Apply to become an approved member" }
      end

      context "have applied, pending" do
        let(:application) { FactoryBot.build(:approved_user_application) }
        it { expect(page).to have_content "You have applied to become an approved member." }
        it { expect(page).to have_no_link "Apply to become an approved member" }
      end

      context "have applied, accepted" do
        let!(:user) { FactoryBot.create(:user, :approved) }
        it { expect(page).to have_content "You are an approved member!" }
        it { expect(page).to have_no_link "Apply to become an approved member" }
      end

      context "have applied, declined" do
        let(:application) { FactoryBot.build(:approved_user_application, status: :declined) }
        it { expect(page).to have_content "Unfortunately, we have not approved your application." }
        it { expect(page).to have_link "Apply to become an approved member" }
      end
    end
  end
end
