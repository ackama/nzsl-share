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
  end

  describe "Removing a folder" do
    let!(:folders) { FactoryBot.create_list(:folder, 3, user: process.user) }
    before { process.start }

    it "removes the folder" do
      process.remove_folder
      expect(process).to have_selector(".folder", count: folders.size - 1)
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
  end
end
