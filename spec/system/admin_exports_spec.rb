require "rails_helper"

RSpec.describe "Admin: Exports", type: :system do
  let(:administrator) { FactoryBot.create(:user, :administrator) }
  before do
    sign_in administrator
    visit admin_exports_path
  end

  it "displays the page title" do
    expect(page).to have_title("Export data")
  end

  it "displays an option to download published signs" do
    expect(page).to have_link("Download published signs (CSV format)", href: published_signs_admin_exports_path)
  end

  it "displays an option to download user data" do
    expect(page).to have_link("Download user data (CSV format)", href: users_admin_exports_path)
  end
end
