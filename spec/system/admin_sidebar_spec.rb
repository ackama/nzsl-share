require "rails_helper"

RSpec.describe "The admin sidebar", type: :system do
  let!(:admin) { FactoryBot.create(:user, :administrator) }
  let!(:users) { FactoryBot.create_list(:user, 3) }
  let(:auth) { AuthenticateFeature.new(admin) }

  before { auth.sign_in }

  it "links to signs dashboard" do
    click_on "Moderate signs"
    expect(page).to have_current_path(admin_signs_path)
  end

  it "links to users dashboard" do
    click_on "User admin"
    expect(page).to have_current_path(admin_users_path)
  end
end
