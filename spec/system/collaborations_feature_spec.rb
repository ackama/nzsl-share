require "rails_helper"

RSpec.describe "Collaborative Folders", type: :system do
  let(:process) { FolderFeature.new }

  describe "Managing collaborations" do
    let!(:folder) { FactoryBot.create(:folder, user: process.user) }
    let!(:collab_folder) { FactoryBot.create(:folder) }

    before do
      collab_folder.collaborators << process.user
      folder.collaborators.destroy_all
      process.start
    end

    context "user is a collaborator", uses_javascript: true do
      it "is allowed" do
        process.within_specific_list_item_menu(collab_folder.title, dropdown: true) do
          expect(page).to have_link "Collaborators"
        end
      end
    end

    context "user is not a collaborator", uses_javascript: true do
      it "is not allowed" do
        process.within_specific_list_item_menu(folder.title, dropdown: true) do
          expect(page).not_to have_link "Collaborators"
        end
      end
    end
  end

  describe "Creating a new collaboration" do
    let!(:folder) { FactoryBot.create(:folder, user: process.user) }
    let!(:collaborator) { FactoryBot.create(:user) }

    before { process.start }

    shared_examples "by email" do
      it "successfully adds new collaborator" do |example|
        process.manage_collaborators(dropdown: example.metadata[:uses_javascript])
        process.enter_identifier(collaborator.email)
        process.submit_new_collaborator_form
        expect(process).to have_content "Successfully added collaborator to folder."
      end

      it "sends an email invite if collaborator doesn't have an account" do |example|
        process.manage_collaborators(dropdown: example.metadata[:uses_javascript])
        process.enter_identifier("fake@email.com")
        process.submit_new_collaborator_form
        expect(process).to have_content "Successfully added collaborator to folder."
      end
    end

    shared_examples "by username" do
      it "successfully adds new collaborator" do |example|
        process.manage_collaborators(dropdown: example.metadata[:uses_javascript])
        process.enter_identifier(collaborator.username)
        process.submit_new_collaborator_form
        expect(process).to have_content "Successfully added collaborator to folder."
      end

      it "shows validation error if username doesn't exist" do |example|
        process.manage_collaborators(dropdown: example.metadata[:uses_javascript])
        process.enter_identifier("idontexist")
        process.submit_new_collaborator_form
        expect(process).to have_content "This username does not exist"
      end
    end

    context "inside modal", uses_javascript: true do
      it_behaves_like "by email"
      it_behaves_like "by username"
    end
  end

  describe "Removing a collaborator" do
    let!(:folder) { FactoryBot.create(:folder, user: process.user) }
    let!(:collaborator) { FactoryBot.create(:user) }

    before do
      folder.collaborators << collaborator
      process.start
    end

    context "who is NOT the current user", uses_javascript: true do
      it "successfully" do
        process.manage_collaborators(dropdown: true)
        within ".modal-form__fields", match: :first do
          process.find("div", text: collaborator.email, visible: true).sibling("div").click
        end
        confirmation = page.driver.browser.switch_to.alert
        expect(confirmation.text).to eq I18n.t!("collaborations.destroy.confirm")
      end
    end

    context "who IS the current user", uses_javascript: true do
      it "successfully" do
        process.manage_collaborators(dropdown: true)
        within ".modal-form__fields", match: :first do
          process.find("div", text: process.user.email, visible: true).sibling("div").click
        end
        confirmation = page.driver.browser.switch_to.alert
        expect(confirmation.text).to eq I18n.t!("collaborations.destroy.confirm")
      end
    end
  end
end
