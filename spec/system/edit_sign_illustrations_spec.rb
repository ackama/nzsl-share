require "rails_helper"

RSpec.describe "Edit sign illustrations", type: :system do
  include FileUploads
  include WaitForAjax
  include ActionView::Helpers::NumberHelper

  let(:user) { FactoryBot.create(:user, :approved) }
  let(:sign) { FactoryBot.create(:sign, :unprocessed, contributor: user) }
  subject { page }

  before do
    sign_in user
    visit edit_sign_path(sign)
  end

  it "can specify illustrations for a sign", uses_javascript: true, upload_mode: :uppy do
    within ".illustrations" do
      click_on "Upload files"

      # Invalid file has an error
      choose_file Rails.root.join("spec/fixtures/dummy.exe"), selector: "files[]", visible: false, match: :first
      expect(page).to have_content "You can only upload: image/*"

      # Block too many files
      choose_file Rails.root.join("spec/fixtures/image.png"), selector: "files[]", visible: false, match: :first
      click_on "Add more"
      choose_file Rails.root.join("spec/fixtures/image.jpeg"), selector: "files[]", visible: false, match: :first
      click_on "Add more"
      choose_file Rails.root.join("spec/fixtures/image.gif"), selector: "files[]", visible: false, match: :first
      expect(page).not_to have_button "Add more"

      click_on "Upload 3 files"
    end

    expect(page).to have_selector(".sign-illustrations > *", count: 3)
  end

  it "can drag and drop illustrations for a sign", uses_javascript: true, upload_mode: :uppy do
    within ".illustrations" do
      click_on "Upload files"
      expect(page).to have_selector(".uppy-Dashboard")
      drop_file Rails.root.join("spec/fixtures/dummy.exe"), selector: ".uppy-Dashboard"
      expect(page).to have_content "You can only upload: image/*"

      drop_file("spec/fixtures/image.png", selector: ".uppy-Dashboard")
      drop_file("spec/fixtures/image.jpeg", selector: ".uppy-Dashboard")
      drop_file("spec/fixtures/image.gif", selector: ".uppy-Dashboard")
      drop_file("spec/fixtures/image.webp", selector: ".uppy-Dashboard")
      expect(page).to have_content "You can only upload 3 file(s) at a time"

      click_on "Upload 3 files"
    end

    expect(page).to have_selector(".sign-illustrations > *", count: 3)
  end

  it "can specify illustrations for a sign without javascript", uses_javacript: false, upload_mode: :legacy do
    within(".illustrations") { choose_file Rails.root.join("spec/fixtures/image.png") }
    click_on "Update Sign"
    expect(page).to have_content I18n.t("signs.update.success")
    visit edit_sign_path(sign)
    expect(page).to have_selector(".sign-illustrations > *")
  end

  it "can specify illustrations for a sign using the legacy uploader", uses_javascript: true, upload_mode: :legacy do
    within ".illustrations" do
      choose_file Rails.root.join("spec/fixtures/image.png")
      expect(page).to have_selector(".sign-illustrations > *", count: 1)
      choose_file Rails.root.join("spec/fixtures/image.jpeg")
      expect(page).to have_selector(".sign-illustrations > *", count: 2)
      choose_file Rails.root.join("spec/fixtures/image.gif")
      expect(page).to have_selector(".sign-illustrations > *", count: 3)
    end
  end
end
