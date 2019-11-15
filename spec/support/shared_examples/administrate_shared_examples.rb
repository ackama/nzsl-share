RSpec.shared_examples "an Administrate dashboard" do |url_base, only: %i[index show new edit destroy], except: []|
  include AdministratePageHelpers
  actions = only - except

  before { visit_admin url_base }

  if actions.include?(:index)
    it "can visit the index page" do
      expect(page).to have_selector("tr.js-table-row")
    end
  end

  if actions.include?(:new)
    it "can visit the new page" do
      expect(page).to click_on "New #{url_base.to_s.titleize}"
    end
  end

  if actions.include?(:show)
    it "can visit the show page" do
      click_on_first_row
      expect(header).to start_with "Show"
    end
  end

  if actions.include?(:edit)
    it "can visit the edit page" do
      within(first_row) { click_on "Edit" }
      expect(header).to start_with "Edit"
    end
  end

  if actions.include?(:destroy)
    it "can destroy a record" do
      within(mid_row) { click_on "Destroy" }
      expect(page).to have_content "was successfully destroyed."
    end
  end
end
