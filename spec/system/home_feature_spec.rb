require "rails_helper"

RSpec.describe "Homepage", type: :system do
  let!(:recently_added_signs) { FactoryBot.create_list(:sign, 5, :published) }

  before { visit root_path }

  it "rendered page contains both base and application layouts" do
    assert_selector("html>head+body")
    assert_selector("body p")
    assert_match(/Home/, page.title)
  end

  it "header search nav is not visible initially", uses_javascript: true do
    expect(page).to have_css("#header-nav", visible: false)
  end

  it "header search shows and hides on scroll", uses_javascript: true do
    signs = page.find(".home-main__signs", match: :first)
    hero_unit = page.find(".hero-unit")
    page.scroll_to(signs)
    expect(page).to have_css("#header-nav", visible: true)
    page.scroll_to(hero_unit)
    expect(page).to have_css("#header-nav", visible: false)
  end

  context "recently added signs" do
    it "shows recently published heading" do
      expect(page).to have_selector "h2:contains('Recently Added')"
    end

    it "shows the 4 most recently published signs" do
      within "#recently-published" do
        expect(page).to have_selector ".sign-grid .sign-card", count: 4
      end
    end
  end
end
