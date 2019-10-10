require "rails_helper"

RSpec.describe "Folders", type: :system do
  let(:process) { FolderFeature.new }
  before { process.start }

  describe "Creating a new folder", uses_javascript: true do
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

  describe "Creating a new folder without JS" do
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

  describe "Removing a folder" do
    let!(:folders) { FactoryBot.create_list(:folder, 3, user: process.user) }
    before { process.start }

    it "removes the folder" do
      process.remove_folder
      expect(process).to have_selector(".folder", count: folders.size - 1)
    end

    it "posts a success message" do
      process.remove_folder
      expect(process).to have_content "Folder was deleted successfully"
    end
  end
end
