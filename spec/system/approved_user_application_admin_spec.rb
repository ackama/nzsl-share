require "rails_helper"

RSpec.describe "Approved user applications administration", type: :system do
  include AdministratePageHelpers

  let!(:admin) { FactoryBot.create(:user, :administrator) }
  let!(:application) { FactoryBot.create(:approved_user_application) }
  let(:auth) { AuthenticateFeature.new(admin) }

  before do
    auth.sign_in
    click_on "User approvals"
  end

  it_behaves_like "an Administrate dashboard", :approved_user_applications, except: %i[destroy edit new]

  describe "accepting" do
    before { click_on_first_row }
    subject { page }

    it { is_expected.to have_current_path("/admin/approved_user_applications/#{application.id}") }
    it { is_expected.to have_link "Accept" }
    it { expect { click_on("Accept"); application.reload }.to change(application, :accepted?).to eq true }
    it { click_on("Accept"); expect(page).to have_content "User application was accepted. The user was approved." }

    context "already accepted" do
      let!(:application) { FactoryBot.create(:approved_user_application).tap(&:accept!) }
      it { is_expected.not_to have_link "Accept" }
    end
  end

  describe "declining" do
    before { click_on_first_row }
    subject { page }

    it { is_expected.to have_current_path("/admin/approved_user_applications/#{application.id}") }
    it { is_expected.to have_link "Decline" }
    it { expect { click_on("Decline"); application.reload }.to change(application, :declined?).to eq true }
    it { click_on("Decline"); expect(page).to have_content "User application was declined." }

    context "already declined" do
      let!(:application) { FactoryBot.create(:approved_user_application).tap(&:decline!) }
      it { is_expected.not_to have_link "Decline" }
    end
  end
end
