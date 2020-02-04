require "rails_helper"

RSpec.describe "Folders", type: :system do
  let(:process) { FolderFeature.new }

  describe "Creating a new folder" do
    before { process.start }

    shared_examples "creating a folder" do
      it "can add a new folder successfully" do
        title = "My Folder"
        description = "Signs I like"
        process.click_create_new
        process.enter_title(title)
        process.enter_description(description)
        process.submit_new_folder_form
        expect(process).to have_content "Folder successfully created."
        expect(process).to have_content(title)
      end

      it "displays correct validation errors" do
        process.click_create_new
        process.submit_new_folder_form
        expect(process).to have_content "can't be blank"
      end
    end

    context "using a modal", uses_javascript: true do
      it_behaves_like "creating a folder"
    end

    it_behaves_like "creating a folder", uses_javascript: false
  end

  describe "Editing a folder" do
    let!(:folder) { FactoryBot.create(:folder, user: process.user) }
    before { process.start }

    shared_examples "editing a folder" do
      it "updates the folder successfully" do |example|
        title = folder.title
        process.edit_folder(dropdown: example.metadata[:uses_javascript])
        process.enter_title(title + " CHANGED")
        process.submit_edit_folder_form
        expect(process).to have_content "Folder successfully updated."
        expect(process).to have_content(title + " CHANGED")
      end

      it "displays correct validation errors" do |example|
        process.edit_folder(dropdown: example.metadata[:uses_javascript])
        process.enter_title("")
        process.submit_edit_folder_form
        expect(process).to have_content "can't be blank"
      end
    end

    context "inside modal", uses_javascript: true do
      it_behaves_like "editing a folder"
    end

    context "without JS" do
      it_behaves_like "editing a folder"
    end

    context "as a collaborator" do
      let!(:collab_folder) { FactoryBot.create(:folder) }
      before do
        collab_folder.collaborators << process.user
        process.start
      end

      it "can edit the folder", uses_javascript: true do
        process.within_specific_list_item_menu(collab_folder.title, dropdown: true) do
          click_on "Edit"
        end
        process.enter_title(title + " CHANGED")
        process.submit_edit_folder_form
        expect(process).to have_content "Folder successfully updated."
        expect(process).to have_content(title + " CHANGED")
      end
    end
  end

  describe "Removing a folder" do
    let!(:folders) { FactoryBot.create_list(:folder, 3, user: process.user) }
    before { process.start }

    it "removes the folder" do
      process.remove_folder
      expect(process).to have_selector(".list__item", count: folders.size - 1)
    end

    it "does not show delete link of the folder if it's the last one" do
      # Delete all but the first folder
      folders[1..-1].each(&:destroy)
      process.start
      process.within_list_item_menu do
        expect(page).to have_no_link "Delete"
      end
    end

    it "posts a success message" do
      process.remove_folder
      expect(process).to have_content "Folder successfully deleted."
    end

    it "confirms before deleting with JS", uses_javascript: true do
      process.remove_folder(dropdown: true)
      confirmation = page.driver.browser.switch_to.alert
      expect(confirmation.text).to eq I18n.t!("folders.destroy.confirm")
    end

    context "as a collaborator" do
      let!(:collab_folder) { FactoryBot.create(:folder) }
      before do
        collab_folder.collaborators << process.user
        process.start
      end

      it "cannot delete the folder", uses_javascript: true do
        process.within_specific_list_item_menu(collab_folder.title, dropdown: true) do
          expect(page).to have_no_link "Delete"
        end
      end
    end
  end

  describe "The folders index page" do
    let!(:folder) { FactoryBot.create(:folder, user: process.user) }
    let!(:collab_folder) { FactoryBot.create(:folder) }

    before do
      collab_folder.collaborators << process.user
      process.start
    end

    it "has the expected page title" do
      expect(page).to have_title "My Folders – NZSL Share"
    end

    it "links folder titles to their corresponding show page" do
      click_on folder.title
      expect(page).to have_current_path(folder_path(folder))
    end

    it "displays all the appropriate folders" do
      expect(page).to have_content(folder.title)
      expect(page).to have_content(collab_folder.title)
    end
  end

  describe "The folder show page" do
    let!(:folder) { FactoryBot.create(:folder, user: process.user) }
    before do
      process.start
      click_on folder.title
    end

    it "has the expected page title" do
      expect(page).to have_title "#{folder.title} – NZSL Share"
    end

    it "renders the folder title" do
      expect(page).to have_content folder.title
    end

    it "renders the manage collaborators button" do
      expect(page).to have_content "Manage team"
    end
  end
end
