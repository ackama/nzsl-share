require "rails_helper"

RSpec.describe "Profile page", type: :system do
  let!(:user) { FactoryBot.create(:user) }

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
