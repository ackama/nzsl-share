require "rails_helper"

RSpec.describe "Approved user applications administration", type: :system do
  include AdministratePageHelpers

  let!(:admin) { FactoryBot.create(:user, :administrator) }
  let!(:application) { FactoryBot.create(:approved_user_application) }

  before do
    sign_in admin
    visit root_path
    within ".sidebar--inside-grid" do
      click_on "User approvals"
    end
  end

  it_behaves_like "an Administrate dashboard", :approved_user_applications, except: %i[destroy edit new]

  describe "accepting" do
    before { click_on_first_row }

    it "can view a user approval application" do
      expect(page).to have_current_path("/admin/approved_user_applications/#{application.id}")
    end

    it "can accept an approved user application" do
      expect(page).to have_link "Accept"
      click_link "Accept"
      expect { application.reload }.to change(application, :accepted?).to eq true
      expect(page).to have_content "User application was accepted. The user was approved."
    end

    context "already accepted" do
      let!(:application) { FactoryBot.create(:approved_user_application).tap(&:accept!) }
      it "does not show accept link" do
        expect(page).to have_no_link "Accept"
      end
    end
  end

  describe "declining" do
    before { click_on_first_row }

    it "can view a user approval application" do
      expect(page).to have_current_path("/admin/approved_user_applications/#{application.id}")
    end

    it "can accept an approved user application" do
      expect(page).to have_link "Decline"
      click_link "Decline"
      expect { application.reload }.to change(application, :declined?).to eq true
      expect(page).to have_content "User application was declined."
    end

    context "already declined" do
      let!(:application) { FactoryBot.create(:approved_user_application).tap(&:decline!) }
      it "does not show decline link" do
        expect(page).to have_no_link "Decline"
      end
    end
  end
end
