require "rails_helper"

RSpec.describe "User administration", type: :system do
  include AdministratePageHelpers
  let!(:admin) { FactoryBot.create(:user, :administrator) }
  let!(:users) { FactoryBot.create_list(:user, 3) }
  let(:auth) { AuthenticateFeature.new(admin) }

  before { visit_admin(:users, admin: admin) }

  it_behaves_like "an Administrate dashboard", :users, except: %i[destroy new]

  it "excludes unconfirmed users by default" do
    confirmed_user = FactoryBot.create(:user)
    unconfirmed_user = FactoryBot.create(:user, confirmed_at: nil)
    visit_admin(:users, admin: admin)
    expect(page).to have_no_content(unconfirmed_user.email)
    expect(page).to have_content(confirmed_user.email)
  end

  context "filtering" do
    context "using dropdown" do
      it "filters by administrator" do
        select "Administrator", from: "status"
        expect(page).to have_field "search", with: "administrator:"
      end

      it "filters by moderator" do
        select "Moderator", from: "status"
        expect(page).to have_field "search", with: "moderator:"
      end

      it "filters by validator" do
        select "Validator", from: "status"
        expect(page).to have_field "search", with: "validator:"
      end

      it "filters by basic" do
        select "Basic", from: "status"
        expect(page).to have_field "search", with: "basic:"
      end

      it "filters by approved" do
        select "Approved", from: "status"
        expect(page).to have_field "search", with: "approved:"
      end

      it "filters by unconfirmed" do
        select "Unconfirmed", from: "status"
        expect(page).to have_field "search", with: "unconfirmed:"
      end
    end
  end
end
