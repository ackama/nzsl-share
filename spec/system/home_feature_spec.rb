require "rails_helper"

RSpec.describe "Homepage", type: :system do
  before do
    FactoryBot.create_list(:sign, 10)
    visit root_path
  end

  it "rendered page contains both base and application layouts" do
    assert_selector("html>head+body")
    assert_selector("body p")
    assert_match(/Home/, page.title)
  end

  it "header search nav is not visible initially", uses_javascript: true do
    expect(page).to have_css("#header-nav", visible: false)
  end

  it "header search shows and hides on scroll", uses_javascript: true do
    signs = page.find(".copy__signs", match: :first)
    hero_unit = page.find(".hero-unit")
    execute_script("arguments[0].scrollIntoView();", signs)
    expect(page).to have_css("#header-nav", visible: true)
    execute_script("arguments[0].scrollIntoView();", hero_unit)
    expect(page).to have_css("#header-nav", visible: false)
  end

  it "displays recently added and most viewed signs" do
    page.all(".sign-grid").each do |element|
      expect(element).to have_css(".sign-card", count: 4)
    end
  end
end
