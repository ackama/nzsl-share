require "rails_helper"

RSpec.describe "Adding and removing signs to folders from the card view", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let!(:sign) { FactoryBot.create(:sign, :published, contributor: user) }

  before do |example|
    sign_in user unless example.metadata[:signed_out]
    visit root_path
  end

  def sign_card
    find(".sign-card", match: :first)
  end

  context "with JS", uses_javascript: true do
    let(:folder) { FactoryBot.create(:folder, user: user) }
    let!(:other_folder) { FactoryBot.create(:folder, user: user) }
    let!(:collab_folder) { FactoryBot.create(:folder) }
    let!(:empty_collab_folder) { FactoryBot.create(:folder) }
    let!(:folder_membership) { FolderMembership.create(folder: folder, sign: sign) }
    let!(:collab_folder_membership) { FolderMembership.create(folder: collab_folder, sign: sign) }
    # We have added records so need to reload
    before do
      collab_folder.collaborators << user
      empty_collab_folder.collaborators << user

      visit topic_path(sign.topics.first)
    end

    it "shows existing folder state" do
      within sign_card do
        click_on "Folders"
        active_checkbox = page.find_field("membership_folder_#{folder.id}_sign_#{sign.id}")
        inactive_checkbox = page.find_field("membership_folder_#{other_folder.id}_sign_#{sign.id}")
        inactive_collab_checkbox = page.find_field("membership_folder_#{empty_collab_folder.id}_sign_#{sign.id}")
        expect(active_checkbox).to be_checked
        expect(inactive_checkbox).not_to be_checked
        expect(inactive_collab_checkbox).not_to be_checked
        expect(page).to have_selector ".sign-card__folders__button--in-folder"
      end
    end

    it "adds the sign to an owned folder" do
      within sign_card do
        click_on "Folders"
        expect do
          page.find("label", text: other_folder.title).click
          wait_for_ajax
        end.to change(FolderMembership, :count).by(1)
      end
    end

    it "adds the sign to a collaborative folder" do
      within sign_card do
        click_on "Folders"
        expect do
          page.find("label", text: empty_collab_folder.title).click
          wait_for_ajax
        end.to change(FolderMembership, :count).by(1)
      end
    end

    it "updates the signs count on another sign card automatically" do
      FactoryBot.create(:sign, :published, topics: sign.topics)

      # We have added records so need to reload
      visit topic_path(sign.topics.first)

      cards = all(".sign-card")
      this_card = cards.first
      other_card = cards.last

      within(this_card) do
        click_on "Folders"
        page.find("label", text: other_folder.title).click
      end

      wait_for_ajax

      within(other_card) do
        click_on "Folders"
        expect(page).to have_text "#{other_folder.title}\n(1)"
      end
    end

    it "removes a sign from an owned folder" do
      within sign_card do
        click_on "Folders"
        expect do
          page.find("label", text: folder.title).click
          wait_for_ajax
        end.to change(FolderMembership, :count).by(-1)
      end
    end

    it "removes a sign from a collab folder" do
      within sign_card do
        click_on "Folders"
        expect do
          page.find("label", text: collab_folder.title).click
          wait_for_ajax
        end.to change(FolderMembership, :count).by(-1)
      end
    end

    it "links the user to sign in page if they are logged out", signed_out: true do
      original_path = current_path
      find(".sign-card__folders__button", match: :first).click
      expect(page).to have_current_path(new_user_session_path)
      within "form#new_user" do
        fill_in "Username/Email", with: user.email
        fill_in "Password", with: user.password
        click_on "Log in"
      end
      expect(page).to have_current_path(original_path)
    end
  end

  context "without JS" do
    let(:folder) { FactoryBot.create(:folder, user: user) }
    let!(:other_folder) { FactoryBot.create(:folder, user: user) }
    let!(:folder_membership) { FolderMembership.create(folder: folder, sign: sign) }

    # We have added records so need to reload
    before { visit current_path }

    it "shows existing folder state" do
      within sign_card do
        expect(page).to have_selector ".sign-card__folders__button--in-folder"
        within ".sign-card__folders__menu" do
          expect(page).to have_content folder.title
        end
      end
    end

    it "adds the sign to a folder" do
      within sign_card do
        within ".sign-card__folders__menu" do
          select other_folder.title, from: "Add to Folder:"
          click_on "Save"
        end
      end

      expect(page).to have_content I18n.t("folder_memberships.create.success",
                                          sign: sign.word,
                                          folder: other_folder.title)
    end

    it "removes the sign from a folder" do
      within sign_card do
        within ".sign-card__folders__menu" do
          click_on "Remove from Folder"
        end
      end

      expect(page).to have_content I18n.t("folder_memberships.destroy.success",
                                          sign: sign.word,
                                          folder: folder.title)
    end

    it "links the user to sign in page if they are logged out", signed_out: true do
      original_path = current_path
      sign_card_folder = find(".sign-card__folders", match: :first)
      within sign_card_folder do
        click_on("Folders")
      end
      expect(page).to have_current_path(new_user_session_path)
      within "form#new_user" do
        fill_in "Username/Email", with: user.email
        fill_in "Password", with: user.password
        click_on "Log in"
      end
      expect(page).to have_current_path(original_path)
    end
  end
end
