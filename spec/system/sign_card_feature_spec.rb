require "rails_helper"

RSpec.describe "Sign card features", type: :system do
  let!(:sign) { FactoryBot.create(:sign) }
  let(:presenter) { SignPresenter.new(sign, ActionView::Base.new) }
  let(:authenticator) { AuthenticateFeature.new }

  # Run all these examples within the context of the sign
  # card DOM element
  around do |example|
    authenticator.sign_in unless example.metadata[:signed_out]
    # Topic will show the sign in a card
    visit topic_path(sign.topic)
    within(find(".sign-card", match: :first), &example.run)
  end

  def inside_card(&block)
    within(find(".sign-card", match: :first), &block)
  end

  it "shows the title" do
    expect(page).to have_selector ".sign-card__title", text: sign.english
  end

  it "shows the contributor's username" do
    expect(page).to have_content sign.contributor.username
  end

  it "shows a formatted date" do
    expect(page).to have_content presenter.friendly_date
  end

  it "shows the embedded media" do
    expect(page).to have_selector ".sign-card__media > iframe[src^='https://player.vimeo.com']"
  end

  describe "Adding & removing from folders with JS" do
    it "shows existing folder state"
    it "adds the sign to a folder"
    it "removes the sign from a folder"
  end

  describe "Adding & removing from folders without JS" do
    let(:folder) { FactoryBot.create(:folder, user: authenticator.user) }
    let!(:other_folder) { FactoryBot.create(:folder, user: authenticator.user) }
    let!(:folder_membership) { FolderMembership.create(folder: folder, sign: sign) }

    # We have added records so need to reload
    before { visit current_path }

    it "shows existing folder state" do
      inside_card do
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
                                          sign: sign.english,
                                          folder: other_folder.title)
    end

    it "removes the sign from a folder" do
      inside_card do
        within ".sign-card__folders__menu" do
          click_on "Remove from Folder"
        end
      end

      expect(page).to have_content I18n.t("folder_memberships.destroy.success",
                                          sign: sign.english,
                                          folder: folder.title)
    end

    it "does not show the folder icon", signed_out: true do
      expect(page).not_to have_selector ".sign-card__folders"
    end
  end
end
