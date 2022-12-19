RSpec.shared_examples "an Administrate dashboard" do |only: %i[index show new edit destroy], except: []|
  include AdministratePageHelpers
  actions = only - except

  if actions.include?(:index)
    it "can visit the index page" do
      expect(page).to have_selector("tr.js-table-row")
    end
  end

  if actions.include?(:new)
    it "can create a new record" do
      within ".list__title" do
        find(:css, ".button.royal.primary").click
      end
      expect(header).to start_with "New"
    end
  end

  if actions.include?(:show)
    it "can visit the show page" do
      click_on_first_row
      expect(header).to start_with "Show"
    end
  end

  if actions.include?(:edit)
    it "can visit the edit page", uses_javascript: true do
      within(first_row) { click_on "Options" }
      within(".list__item-menu", match: :first) do
        click_on "Edit"
      end
      expect(header).to start_with "Edit"
    end
  end

  if actions.include?(:destroy)
    it "can destroy a record", uses_javascript: true do
      within(first_row) { click_on "Options" }
      within(".list__item-menu", match: :first) do
        accept_confirm do
          click_link("Delete")
        end
      end
      expect(page).to have_content "was successfully destroyed."
    end
  end
end
