require "rails_helper"

RSpec.describe "Sign card features", type: :system do
  let(:user) { FactoryBot.create(:user) }
  let!(:sign) { FactoryBot.create(:sign, contributor: user) }
  let(:presenter) { SignPresenter.new(sign, ActionView::Base.new) }
  let(:authenticator) { AuthenticateFeature.new(user) }

  before do |example|
    authenticator.sign_in unless example.metadata[:signed_out]
    visit topic_path(sign.topic)
  end

  def sign_card
    find(".sign-card", match: :first)
  end

  def inside_card(&block)
    within(sign_card, &block)
  end

  it "shows the title" do
    expect(sign_card).to have_selector ".sign-card__title", text: sign.word
  end

  it "shows the contributor's username" do
    expect(sign_card).to have_content sign.contributor.username
  end

  it "shows a formatted date" do
    expect(sign_card).to have_content presenter.friendly_date
  end

  it "shows the sign status" do
    expect(sign_card).to have_content "private"
    title = find("#sign_status")["title"]
    assert_equal(title, I18n.t!("signs.personal.description"))
  end

  it "does not show the sign status if they are logged out", signed_out: true do
    expect(sign_card).not_to have_content "private"
  end

  it "shows the embedded media" do
    expect(sign_card).to have_selector ".sign-card__media > .video-wrapper > video.video"
  end

  it "shows the Māori gloss" do
    expect(sign_card).to have_selector ".sign-card__supplementary-titles__maori", text: sign.maori
  end

  it "shows the secondary gloss" do
    expect(sign_card).to have_selector ".sign-card__supplementary-titles__secondary", text: sign.secondary
  end

  describe "Adding & removing from folders with JS", uses_javascript: true do
    let(:folder) { FactoryBot.create(:folder, user: authenticator.user) }
    let!(:other_folder) { FactoryBot.create(:folder, user: authenticator.user) }
    let!(:folder_membership) { FolderMembership.create(folder: folder, sign: sign) }
    let(:user) { authenticator.user }

    # We have added records so need to reload
    before { visit topic_path(sign.topic) }

    it "shows existing folder state" do
      inside_card do
        click_on "Folders"
        active_checkbox = page.find_field("membership_folder_#{folder.id}_sign_#{sign.id}")
        inactive_checkbox = page.find_field("membership_folder_#{other_folder.id}_sign_#{sign.id}")
        expect(active_checkbox).to be_checked
        expect(inactive_checkbox).not_to be_checked
        expect(page).to have_selector ".sign-card__folders__button--in-folder"
      end
    end

    it "adds the sign to a folder" do
      inside_card do
        click_on "Folders"
        expect do
          page.find("label", text: other_folder.title).click
          wait_for_ajax
        end.to change(FolderMembership, :count).by(1)
      end
    end

    it "updates the signs count on another sign card automatically" do
      FactoryBot.create(:sign, topic: sign.topic)

      # We have added records so need to reload
      visit topic_path(sign.topic)

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

    it "removes the sign from a folder" do
      inside_card do
        click_on "Folders"
        expect do
          page.find("label", text: folder.title).click
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

  describe "Adding & removing from folders without JS" do
    let(:folder) { FactoryBot.create(:folder, user: user) }
    let!(:other_folder) { FactoryBot.create(:folder, user: user) }
    let!(:folder_membership) { FolderMembership.create(folder: folder, sign: sign) }

    # We have added records so need to reload
    before { visit current_path }

    it "shows existing folder state" do
      inside_card do
        expect(page).to have_selector ".sign-card__folders__button--in-folder"
        within ".sign-card__folders__menu" do
          expect(page).to have_content folder.title
        end
      end
    end

    it "adds the sign to a folder" do
      inside_card do
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
      inside_card do
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
      within ".sign-card__folders" do
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

  shared_examples "sign card voting" do
    it "is able to register an agree" do
      within sign_card do
        click_on "Agree"
        expect(page).to have_selector ".sign-card__votes--agreed", text: "1"
      end
    end

    it "is able to deregister an agree" do
      within sign_card do
        click_on "Agree"
        expect(page).to have_selector ".sign-card__votes--agreed", text: "1"
        click_on "Undo agree"
        expect(page).to have_selector ".sign-card__votes--agree", text: "0"
      end
    end

    it "is able to register a disagree" do
      within sign_card do
        click_on "Disagree"
        expect(page).to have_selector ".sign-card__votes--disagreed", text: "1"
      end
    end

    it "is able to deregister a disagree" do
      within sign_card do
        click_on "Disagree"
        expect(page).to have_selector ".sign-card__votes--disagreed", text: "1"
        click_on "Undo disagree"
        expect(page).to have_selector ".sign-card__votes--disagree", text: "0"
      end
    end

    it "is able to switch from agree to disagree" do
      within sign_card do
        click_on "Agree"
        click_on "Disagree"
        expect(page).to have_selector ".sign-card__votes--agree", text: "0"
        expect(page).to have_selector ".sign-card__votes--disagreed", text: "1"
      end
    end
  end

  describe "Voting" do
    let(:user) { FactoryBot.create(:user, :approved) }

    context "without JS" do
      include_examples "sign card voting"
    end

    context "with JS", uses_javascript: true do
      include_examples "sign card voting"
    end
  end
end
