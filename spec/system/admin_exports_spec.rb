require "rails_helper"

RSpec.describe "Admin: Exports", type: :system do
  let(:administrator) { FactoryBot.create(:user, :administrator) }
  let(:auth) { AuthenticateFeature.new(administrator) }
  before do
    auth.sign_in
    visit admin_exports_path
  end

  it "displays the page title" do
    expect(page).to have_title("Export data")
  end

  it "displays an option to download published signs" do
    expect(page).to have_link("Download published signs (CSV format)", href: published_signs_admin_exports_path)
  end
end
