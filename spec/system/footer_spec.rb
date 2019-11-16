require "rails_helper"

RSpec.describe "Footer", type: :system do
  before do
    visit root_path
  end

  it "has the NZSL logo" do
    expect(page).to have_content("NZSL Share Logo")
  end

  xit "has the NZSL privacy policy link" do
    expect(page).to have_link("Privacy policy")
  end

  xit "has the terms and conditions with link" do
    expect(page).to have_link("Terms & Conditions")
  end

  xit "has an active class for the current page" do
    expect(page).to have_link(root_path)
    expect(page).to have_link(topics_path)
    expect(page).to have_link("/about")
    expect(page).to have_link("/contact")
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

  xit "has a link to the NZSL facebook" do
    expect(page).to have_link "Facebook"
  end

  it "has a link to the NZSL share github repo" do
    expect(page).to have_link "This is an Open Source project."
  end

  it "has the creative commons logo and a link to the conditions" do
    have_css("img[alt=NZSL Dictionary]")
    expect(page).to have_link("Creative Commons Attribution-NonCommericial-ShareAlike 3.0 Unported License.")
  end

  it "has links to the NZSL department at vic uni" do
    expect(page).to have_link("Deaf Studies Research Unit")
    expect(page).to have_link("Victoria University of Wellington")
  end

  it "has a link to view in NZSL" do
    expect(page).to have_link("View in NZSL.")
  end
end
