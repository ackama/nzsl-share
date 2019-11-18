require "rails_helper"

RSpec.describe "Homepage", type: :system do
  let!(:signs) { [] }
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
    execute_script("arguments[0].scrollIntoView();", signs)
    expect(page).to have_css("#header-nav", visible: true)
    execute_script("arguments[0].scrollIntoView();", hero_unit)
    expect(page).to have_css("#header-nav", visible: false)
  end

  context "recently added signs" do
    let!(:signs) { FactoryBot.create_list(:sign, 5, :published) }

    it "shows the 4 most recently published signs" do
      expect(page).to have_selector "h2:contains('Recently Added') + .sign-grid .sign-card", count: 4
    end
  end
end
