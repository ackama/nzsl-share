require "rails_helper"

RSpec.describe "Footer", type: :system do
  before do
    visit root_path
  end

  it "has the NZSL logo" do
    have_css("img[alt=NZSL Share Logo]")
  end

  it "has the NZSL privacy policy link" do
    expect(page).to have_link("Privacy policy")
  end

  it "has the rules with link" do
    expect(page).to have_link("Rules")
  end

  it "displays the sitemap with links" do
    expect(page).to have_link("Home", href: root_path)
    expect(page).to have_link("Topics", href: topics_path)
    expect(page).to have_link("About", href: "/about")
    expect(page).to have_link("Contact", href: "/contact")
  end

  it "has an active class for the current page" do
    within ".footer" do
      current_page = page.find(:css, "li.active")
      expect(current_page).to have_css("a[href='#{root_path}']")
    end
  end

  it "has the learn nzsl logo" do
    have_css("img[alt=Learn NZSL]")
  end

  it "has the nzsl dictionary logo" do
    have_css("img[alt=NZSL Dictionary]")
  end

  it "has a link to the NZSL twitter" do
    expect(page).to have_link "Twitter"
  end

  it "has a link to the NZSL facebook" do
    expect(page).to have_link "Facebook"
  end

  it "has a link to the NZSL share github repo" do
    expect(page).to have_link "This is an Open Source project."
  end

  it "has a link to the NZSL department at vic uni" do
    expect(page).to have_link("© Deaf Studies Research Unit, Victoria University of Wellington")
  end
end
