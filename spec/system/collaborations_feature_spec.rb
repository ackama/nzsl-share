require "rails_helper"

RSpec.describe "Collaborative Folders", type: :system do
  let(:process) { FolderFeature.new }
  let(:user) { FactoryBot.create(:user) }

  describe "Managing collaborations" do
    let!(:folder) { FactoryBot.create(:folder, user:) }
    let!(:collab_folder) { FactoryBot.create(:folder) }

    before do
      sign_in user
      collab_folder.collaborators << user
      folder.collaborators.destroy_all
      process.start
    end

    context "user is a collaborator", uses_javascript: true do
      it "is allowed" do
        process.within_specific_list_item_menu(collab_folder.title, dropdown: true) do
          expect(page).to have_link "Manage team"
        end
      end
    end

    context "user is not a collaborator" do
      it "cannot see the folder" do
        expect(process).to have_no_content folder.title
      end
    end
  end

  describe "Creating a new collaboration", uses_javascript: true do
    let!(:folder) { FactoryBot.create(:folder, user:) }
    let!(:collaborator) { FactoryBot.create(:user) }

    before do
      sign_in user
      process.start
    end

    context "by email" do
      it "successfully adds new collaborator" do
        process.manage_collaborators(dropdown: true)
        process.enter_identifier(collaborator.email)
        process.submit_new_collaborator_form
        expect(process).to have_content "Successfully added team member to this folder."
      end

      it "sends an email invite if collaborator doesn't have an account" do
        process.manage_collaborators(dropdown: true)
        process.enter_identifier("fake@email.com")
        process.submit_new_collaborator_form
        expect(process).to have_content "Successfully added team member to this folder."
      end
    end

    context "by username" do
      it "successfully adds new collaborator" do
        process.manage_collaborators(dropdown: true)
        process.enter_identifier(collaborator.username)
        process.submit_new_collaborator_form
        expect(process).to have_content "Successfully added team member to this folder."
      end

      it "shows validation error if username doesn't exist" do
        process.manage_collaborators(dropdown: true)
        process.enter_identifier("idontexist")
        process.submit_new_collaborator_form
        expect(process).to have_content "This username does not exist"
      end
    end
  end

  describe "Removing a collaborator" do
    let!(:folder) { FactoryBot.create(:folder, user:) }
    let!(:collaborator) { FactoryBot.create(:user) }

    before do
      sign_in user
      folder.collaborators << collaborator
      process.start
    end

    context "who is NOT the current user", uses_javascript: true do
      it "successfully" do
        process.manage_collaborators(dropdown: true)
        within ".modal-form__fields", match: :first do
          process.find("div", text: collaborator.username, visible: true).sibling("div").click
        end
        confirmation = page.driver.browser.switch_to.alert
        expect(confirmation.text).to eq I18n.t!("collaborations.destroy.confirm")
      end
    end

    context "who IS the current user", uses_javascript: true do
      it "successfully" do
        process.manage_collaborators(dropdown: true)
        within ".modal-form__fields", match: :first do
          process.find("div", text: user.username, visible: true).sibling("div").click
        end
        confirmation = page.driver.browser.switch_to.alert
        expect(confirmation.text).to eq I18n.t!("collaborations.destroy.confirm")
      end
    end
  end

  describe "Sign permissions in collaborative folders" do
    let!(:collab_folder) { FactoryBot.create(:folder, user:) }
    let!(:collaborator) { FactoryBot.create(:user) }
    let!(:private_sign) { FactoryBot.create(:sign, :personal, contributor: collaborator) }

    before do
      sign_in user
      collab_folder.collaborators << collaborator
      FolderMembership.create(folder: collab_folder, sign: private_sign)
      process.start
    end

    it "can view other users' private signs in the folder", uses_javascript: true do
      click_on collab_folder.title
      expect(page).to have_content(private_sign.word)
      click_on private_sign.word
      expect(page).to have_current_path sign_path(private_sign.id)
      expect(page).to have_select "comments_in_folder", selected: collab_folder.title
    end

    it "can edit other users' private signs in the folder" do
      visit sign_path(private_sign.id)
      expect(page).to have_content "Hey #{user.username}, you are a collaborator on this sign"
      within "#sign_overview" do
        expect(page).to have_link "Edit"
        click_link "Edit"
      end
      expect(page).to have_current_path edit_sign_path(private_sign.id)
      fill_in "sign_secondary", with: "Antelope"
      click_on "Update Sign"
      expect(page).to have_content I18n.t!("signs.update.success")
    end

    it "cannot submit others' private signs for publishing" do
      visit edit_sign_path(private_sign.id)
      expect(page).to have_no_field "Yes, request my sign be public"
    end

    it "cannot delete others' private signs" do
      visit edit_sign_path(private_sign.id)
      expect(page).to have_no_link I18n.t!("signs.destroy.link")
    end
  end
end
