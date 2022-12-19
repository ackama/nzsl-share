require "rails_helper"

RSpec.describe "The admin sidebar", type: :system do
  let!(:admin) { FactoryBot.create(:user, :administrator) }
  let!(:users) { FactoryBot.create_list(:user, 3) }

  before do
    sign_in admin
    visit root_path
  end

  it "links to signs dashboard" do
    within ".sidebar--inside-grid" do
      click_on "Moderate signs"
      expect(page).to have_current_path(admin_signs_path)
    end
  end

  it "links to users dashboard" do
    within ".sidebar--inside-grid" do
      click_on "User admin"
      expect(page).to have_current_path(admin_users_path)
    end
  end

  it "links to comment reports dashboard" do
    within ".sidebar--inside-grid" do
      click_on "Comment Reports"
      expect(page).to have_current_path(admin_comment_reports_path)
    end
  end

  it "links to the exports page" do
    within ".sidebar--inside-grid" do
      click_on "Export data"
      expect(page).to have_current_path(admin_exports_path)
    end
  end
end
