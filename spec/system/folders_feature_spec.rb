require "rails_helper"

RSpec.describe "Folders", type: :system, uses_javascript: true do
  let(:process) { FolderFeature.new }
  before { process.start }

  it_behaves_like "an accessible page"

  describe "Creating a new folder" do
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
end
