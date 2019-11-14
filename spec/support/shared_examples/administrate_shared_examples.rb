RSpec.shared_examples "an Administrate dashboard" do |url_base|
  include AdministratePageHelpers

  before { visit_admin url_base }

  it "can visit the index page" do
    expect(page).to have_selector("tr.js-table-row")
  end

  it "can visit the show page" do
    click_on_first_row
    expect(header).to start_with "Show"
  end

  it "can visit the edit page" do
    within(first_row) { click_on "Edit" }
    expect(header).to start_with "Edit"
  end

  it "can destroy a record" do
    within(mid_row) { click_on "Destroy" }
    expect(page).to have_content "was successfully destroyed."
  end
end
